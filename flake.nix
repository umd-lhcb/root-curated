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
        root = pkgs.root;
      in
      {
        devShell = pkgs.mkShell {
          name = "root-curated";
          buildInputs = with pythonPackages; [
            pkgs.clang-tools # For clang-format
            root

            # Auto completion
            jedi

            # Linters
            flake8
            pylint
          ];

          #shellHook = ''
            ## fix libstdc++.so not found error
            #export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
          #'';
        };
      });
}
