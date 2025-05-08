final: prev:

{
  # Aliases
  pythonHEP = prev.python310;

  # Libs
  vdt = prev.callPackage ./vdt { python3 = final.pythonHEP; };

  # Latest root
  root = prev.callPackage ./root { python3 = final.pythonHEP; };
  hammer-phys = prev.callPackage ./hammer-phys { };
  hammer-phys-dev = prev.callPackage ./hammer-phys-dev { };
  roounfold = prev.callPackage ./roounfold { };
  roounfold_1_1 = prev.callPackage ./roounfold_1_1 { };

  # ROOT 6.24 stack
  root_6_24_02 = final.root;
  hammer-phys-w_root_6_24 = prev.callPackage ./hammer-phys {
    root = final.root_6_24_02;
  };
  roounfold-w_root_6_24 = prev.callPackage ./roounfold {
    root = final.root_6_24_02;
  };

  # ROOT 5.34
  root_5_34_38 = prev.callPackage ./root_5_34 {
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa OpenGL;
    stdenv = if prev.stdenv.cc.isClang then prev.llvmPackages_5.stdenv else prev.gcc8Stdenv;
    noSplash = true;
  };

  # General utilities
  clang-format-all = prev.callPackage ./clang-format-all { };

  # Haskell overrides
  haskellPackages = prev.haskellPackages.override {
    overrides = _: p:
      {
        time-compat = prev.haskell.lib.dontCheck p.time-compat;
      };
  };
}
