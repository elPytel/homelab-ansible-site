{
  description = "Infrastrukturní repozitář pro Ansible";

  inputs = {
    # Používáme stabilní větev (můžete změnit na nixos-unstable)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # 1. Definice Python prostředí se specifickými knihovnami
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          netaddr    
          proxmoxer  # Pro moduly community.general.proxmox
          requests   # Nutná závislost pro proxmoxer
          jmespath   # Pro komplexní JSON dotazy v Ansible (json_query filtr)
          passlib    # Pro generování hashů hesel přímo v playbooku
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ansible
            ansible-lint
            glibcLocales

            pythonEnv

            # Systémové utility závislé na hostiteli
            sshpass    # Pro fallback autentizaci heslem
            rsync      # Pro synchronizační tasky
            whois      # Poskytuje utilitu mkpasswd
            cdrkit     # Poskytuje genisoimage pro tvorbu cloud-init seed ISO
            git
            gnumake
          ];

          # 3. Hooky spuštěné při aktivaci shellu
          shellHook = ''
            # Oprava lokalizace pro izolované Nix prostředí
            export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
            export LC_ALL=C.UTF-8
            export LANG=C.UTF-8
            
            # Přesměrování cache a logů Ansible do složky projektu
            # Udržuje hostitelský systém (~/.ansible) naprosto čistý
            export ANSIBLE_HOME="$PWD/.ansible_data"
            
            # Nastavení lokálních cest pro stažené role a kolekce
            export ANSIBLE_COLLECTIONS_PATH="$PWD/collections"
            export ANSIBLE_ROLES_PATH="$PWD/roles"

            # Kritické: Vynutí, aby Ansible pro "connection: local" použil náš Nix Python.
            # Jinak by se mohl pokusit použít systémový Python, kde "proxmoxer" chybí.
            export ANSIBLE_PYTHON_INTERPRETER="$(which python)"

            echo "🚀 Nix prostředí pro Ansible aktivováno."
            echo "Python: $(python --version)"
            echo "Ansible: $(ansible --version | awk 'NR==1{print $3}' | tr -d ']')"
          '';
        };
      }
    );
}