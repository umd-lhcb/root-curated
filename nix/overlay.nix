final: prev:

{
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };

  # ROOT 6.24 stack
  root_6_24_02 = final.root.overrideAttrs (oldAttrs: rec {
    patches = oldAttrs.patches ++ [
      ./root/hist_factory.patch
      ./root/hist_factory_branch_optimization.patch
    ];
  });

  # ROOT 6.16 stack
  root_6_16_00 = prev.callPackage ./root_6_16 {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };

  # Older ROOTs
  # ROOT 6.12 doesn't support Python 3 and doesn't build on Big Sur :-(
  # root_6_12_06 = prev.callPackage ./root_6_12 {
  #   python = final.python2;
  #   inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
  #   noSplash = true;
  # };
  root_5_34_38 = prev.callPackage ./root_5_34 {
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa OpenGL;
    stdenv = if prev.stdenv.cc.isClang then prev.llvmPackages_5.stdenv else prev.gcc8Stdenv;
    noSplash = true;
  };

  # General utilities
  clang-format-all = prev.callPackage ./clang-format-all { };
}
