final: prev:

{
  # Dependencies
  vdt = prev.callPackage ./vdt { };
  boost = prev.boost17x; # set default boost to 1.7x

  # Python stuff
  # Make the Python overrides composable. Idea stolen from:
  #   https://github.com/NixOS/nixpkgs/issues/44426#issuecomment-629635102
  pythonOverrides = finalPy: prevPy: {
    # cython = finalPy.callPackage ./python-packages/Cython { };
    # numpy = finalPy.callPackage ./python-packages/numpy { };
    # awkward = finalPy.callPackage ./python-packages/awkward { };
    # boost-histogram = finalPy.callPackage ./python-packages/boost-histogram {
    #   inherit (final) boost;
    # };
    # pyyaml = finalPy.callPackage ./python-packages/pyyaml { };
    # uncertainties = finalPy.callPackage ./python-packages/uncertainties { };
    # uproot = finalPy.callPackage ./python-packages/uproot { };
    # pandas = finalPy.callPackage ./python-packages/pandas { };
    # patsy = finalPy.callPackage ./python-packages/patsy { };
    xgboost = finalPy.callPackage ./python-packages/xgboost {
      inherit (final) xgboost;
    };
    scikit-learn = finalPy.callPackage ./python-packages/scikit-learn {
      inherit (prev) gfortran glibcLocales;
    };
    mplhep = finalPy.callPackage ./python-packages/mplhep { };
    # uhi = finalPy.callPackage ./python-packages/uhi { };
  };
  python3 = prev.python3.override { packageOverrides = final.pythonOverrides; };
  xgboost = prev.callPackage ./xgboost { };

  # Latest root
  root = prev.callPackage ./root {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
  hammer-phys = prev.callPackage ./hammer-phys { };
  hammer-phys-dev = prev.callPackage ./hammer-phys-dev { };
  roounfold = prev.callPackage ./roounfold { };
  roounfold_1_1 = prev.callPackage ./roounfold_1_1 { };

  # ROOT 6.28 stack
  root_6_28_02 = final.root;
  hammer-phys-w_root_6_28 = prev.callPackage ./hammer-phys {
    root = final.root_6_28_02;
  };
  hammer-phys-dev-w_root_6_28 = prev.callPackage ./hammer-phys {
    root = final.root_6_28_02;
  };
  roounfold-w_root_6_28 = prev.callPackage ./roounfold {
    root = final.root_6_28_02;
  };
  roounfold_1_1-w_root_6_28 = prev.callPackage ./roounfold_1_1 {
    root = final.root_6_28_02;
  };

  # ROOT 6.24 stack
  root_6_24_02 = prev.callPackage ./root_6_24 {
    python = final.python3;
    inherit (prev.darwin.apple_sdk.frameworks) Cocoa CoreSymbolication OpenGL;
    noSplash = true;
  };
  hammer-phys-w_root_6_24 = prev.callPackage ./hammer-phys {
    root = final.root_6_24_02;
  };
  hammer-phys-dev-w_root_6_24 = prev.callPackage ./hammer-phys-dev {
    root = final.root_6_24_02;
  };
  roounfold-w_root_6_24 = prev.callPackage ./roounfold {
    root = final.root_6_24_02;
  };
  roounfold_1_1-w_root_6_24 = prev.callPackage ./roounfold_1_1 {
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

  # Haskell overrides
  haskellPackages = prev.haskellPackages.override {
    overrides = _: p:
      {
        time-compat = prev.haskell.lib.dontCheck p.time-compat;
      };
  };
}
