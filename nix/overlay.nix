final: prev:

{
  # Dependencies
  vdt = prev.callPackage ./vdt { };

  # Latest root
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
  hammer-phys = prev.callPackage ./hammer-phys { };
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

  # ROOT 6.16 stack
  root_6_16_00 = prev.callPackage ./root_6_16 {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
  hammer-phys-w_root_6_16 = prev.callPackage ./hammer-phys {
    root = final.root_6_16_00;
  };
  roounfold-w_root_6_16 = prev.callPackage ./roounfold {
    root = final.root_6_16_00;
  };

  # ROOT 6.12 stack
  # NOTE: This doesn't support Python 3 and doesn't build on Big Sur :-(
  root_6_12_06 = prev.callPackage ./root_6_12 {
    python = final.python2;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
  hammer-phys-w_root_6_12 = prev.callPackage ./hammer-phys {
    root = final.root_6_12_06;
  };
  roounfold-w_root_6_12 = prev.callPackage ./roounfold {
    root = final.root_6_12_06;
  };

  # ROOT 5.34
  root_5_34_38 = prev.callPackage ./root_5_34 {
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa OpenGL;
    stdenv = if prev.stdenv.cc.isClang then prev.llvmPackages_5.stdenv else prev.gcc8Stdenv;
    noSplash = true;
  };

  # General utilities
  clang-format-all = prev.callPackage ./clang-format-all { };
}
