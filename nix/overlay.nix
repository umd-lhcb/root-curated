final: prev:

{
  apple_sdk_10_12 = prev.callPackage ./apple-sdk {
    inherit (prev.buildPackages.darwin) print-reexports;
    inherit (prev.darwin) darwin-stubs;
  };
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (final.apple_sdk_10_12.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
}
