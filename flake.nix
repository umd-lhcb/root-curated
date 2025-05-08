{
  description = "A curated version of ROOT 6 w/ HistFactory patches.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-parts, dream2nix, ... } @ inputs:
  flake-parts.lib.mkFlake { inherit inputs; } ({ ... }: {
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    flake.overlays.default = import ./nix/overlay.nix;

    perSystem = { system, pkgs', ... }: rec {
      _module.args.pkgs' = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        config = {
          allowUnfree = true;
          #replaceStdenv = { pkgs, ... }: if pkgs.stdenv.hostPlatform.isLinux then pkgs.gcc11Stdenv else pkgs.stdenv;
        };
      };

      # to generate lock file: `nix run .#py-common-pkgs.lock`
      packages = {
        py-common-pkgs = dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs';
          modules = [
            ./nix/py-common-pkgs.nix
            {
              paths.projectRoot = ./.;
              paths.projectRootFile = "flake.nix";
              paths.package = ./.;
              }
            ];
        };

        # pkgs from overlay
        inherit (pkgs')
          # root
          root
          root_6_24_02
          root_5_34_38
          # hammer
          hammer-phys
          hammer-phys-dev
          # roounfold
          roounfold
          # else
          clang-format-all
          vdt
          git
          isa-l
          ;
      };

      devShells.default = pkgs'.mkShell {
        name = "root-curated-dev";

        inputsFrom = [ packages.py-common-pkgs.devShell ];
        buildInputs = with pkgs'; [
          #root
          #hammer-phys
          #roounfold
        ];
      };
    }; # end of perSystem
  });
}
