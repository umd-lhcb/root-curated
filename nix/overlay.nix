final: prev:

{
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };

  # ROOT 6.12 doesn't support Python 3 :-(
  root_6_12_06 = prev.callPackage ./root_6_12 {
    python = final.python2;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
  root_5_34_38 = prev.callPackage ./root_5_34 {
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa OpenGL;
    noSplash = true;
  };
}
