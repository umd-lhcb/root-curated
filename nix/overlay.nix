final: prev:

{
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };

  root_6_24_00 = final.root.overrideAttrs (oldAttrs: rec {
    version = "6.24.00";
    src = prev.fetchurl {
      url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
      sha256 = "12crjzd7pzx5qpk2pb3z0rhmxlw5gsqaqzfl48qiq8c9l940b8wx";
    };
    patches = oldAttrs.patches ++ [ ./root/hist_factory.patch ];
  });
  root_6_16_00 = prev.callPackage ./root_6_16 {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
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
