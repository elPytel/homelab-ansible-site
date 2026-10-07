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

          # 3. Automatická správa virtuálního prostředí
          VENV=.venv
          if test ! -d $VENV; then
            echo "Vytvářím nové lokální .venv prostředí..."
            python -m venv $VENV
          fi

          # Aktivace prostředí
          source ./$VENV/bin/activate
        '';
      };
    };
}