{ config, lib, dream2nix, ... }: {
  imports = [ dream2nix.modules.dream2nix.WIP-python-pdm ];

  mkDerivation = {
    src = lib.cleanSourceWith {
      src = lib.cleanSource ../.;
      filter = name: type:
        !(builtins.any (x: x) [
          (lib.hasSuffix ".nix" name)
          (lib.hasPrefix "." (builtins.baseNameOf name))
          (lib.hasSuffix "flake.lock" name)
        ]);
    };
  };

  pdm.useUvResolver = true;
  pdm.lockfile = ../pdm.lock;
  pdm.pyproject = ../pyproject.toml;

  # overrides
  deps = { nixpkgs, nixpkgsStable, ... }: {
  };
}
