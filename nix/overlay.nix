final: prev:

{
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (final.darwin.apple_sdk.frameworks) Cocoa OpenGL;
    noSplash = true;
  };
}
