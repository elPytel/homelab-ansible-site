{
  description = "Hybridní Nix + Pip vývojové prostředí";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        # 1. Základní nástroje dodané Nixem
        buildInputs = with pkgs; [
          python311
          python311Packages.pip
          python311Packages.virtualenv
          # Nástroje pro Makefile (Nix nahrazuje apt install)
          yamllint
          ansible-lint
          jq
          # Tyto systémové závislosti se hodí, pokud pip kompiluje něco ze zdrojáků
          stdenv.cc.cc.lib
          zlib
          glibcLocales
        ];

        # 2. Skript, který se spustí při vstupu do složky (přes direnv)
        shellHook = ''
          # Oprava varování s locales
          export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
          export LC_ALL="C.UTF-8"

          # Zpřístupnění systémových C knihoven pro pip wheels
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [
            stdenv.cc.cc.lib
            zlib
          ])}:$LD_LIBRARY_PATH"

          # 3. Automatická správa virtuálního prostředí a profilů
          VENV=.venv
          if test ! -d $VENV; then
            echo "🚀 Vytvářím nové lokální .venv prostředí..."
            python -m venv $VENV
            source ./$VENV/bin/activate

            # Logika pro volbu requirements souboru na základě profilu
            if [ -n "$ANSIBLESITE_PROFILE" ]; then
              REQ_FILE="requirements_$ANSIBLESITE_PROFILE.txt"
              echo "🎯 Zjištěn profil '$ANSIBLESITE_PROFILE'. Použiji $REQ_FILE"
            else
              REQ_FILE="requirements.txt"
              echo "📋 Profil nezadán. Použiji výchozí $REQ_FILE"
            fi

            # Instalace Python závislostí
            if [ -f "$REQ_FILE" ]; then
              echo "📦 Instaluji pip balíčky z $REQ_FILE..."
              pip install -r "$REQ_FILE"
            else
              echo "⚠️ Soubor $REQ_FILE nenalezen, přeskakuji instalaci pip balíčků."
            fi

            # Instalace Ansible rolí a kolekcí
            if [ -f requirements.yml ]; then
              echo "🌌 Stahuji Ansible role a kolekce..."
              export ANSIBLE_ROLES_PATH="$PWD/.ansible/roles"
              export ANSIBLE_COLLECTIONS_PATH="$PWD/.ansible/collections"
              ansible-galaxy install -r requirements.yml --roles-path "$ANSIBLE_ROLES_PATH" --collections-path "$ANSIBLE_COLLECTIONS_PATH"
            fi
          else
            # Prostředí už existuje, pouze ho aktivujeme
            source ./$VENV/bin/activate
            export ANSIBLE_ROLES_PATH="$PWD/.ansible/roles"
            export ANSIBLE_COLLECTIONS_PATH="$PWD/.ansible/collections"
          fi
        '';
      };
    };
}