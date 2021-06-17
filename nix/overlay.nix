final: prev:

{
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (final.darwin.apple_sdk.frameworks) AppKit Cocoa OpenGL;
    noSplash = true;
  };
}
