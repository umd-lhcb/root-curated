{
  description = "A curated version of ROOT 6 w/ HistFactory patches.";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        python = pkgs.python3;
        pythonPackages = python.pkgs;
      in
      {
        devShell = pkgs.mkShell {
          name = "root-curated";
          buildInputs = with pythonPackages; [
            pkgs.clang-tools # For clang-format
            pkgs.root
            python  # For ROOT module test
            #pkgs.nix-info  # For bug report
          ];
        };
      });
}
