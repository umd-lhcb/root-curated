{
  description = "A curated version of ROOT 6 w/ HistFactory patches.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = import ./nix/overlay.nix;
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      rec {
        packages = flake-utils.lib.flattenTree {
          dev-shell = devShell.inputDerivation;
          vdt = pkgs.vdt;

          root = pkgs.root;
          root_6_24_02 = pkgs.root_6_24_02;
          root_6_16_00 = pkgs.root_6_16_00;
          root_5_34_38 = pkgs.root_5_34_38;

          hammer-phys = pkgs.hammer-phys;
          hammer-phys-w_root_6_24 = pkgs.hammer-phys-w_root_6_24;
          hammer-phys-w_root_6_16 = pkgs.hammer-phys-w_root_6_16;

          clang-format-all = pkgs.clang-format-all;
        };
        devShell = pkgs.mkShell {
          name = "root-curated";
          buildInputs = with pkgs; [
            clang-tools  # For clang-format
            root
            python3  # For ROOT module test
            #nix-info  # For bug report
          ];
        };
      });
}
