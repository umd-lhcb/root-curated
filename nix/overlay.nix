final: prev:

{
  # Dependencies
  vdt = prev.callPackage ./vdt { };
  boost = prev.boost17x; # set default boost to 1.7x

  # Python stuff
  # Make the Python overrides composable. Idea stolen from:
  #   https://github.com/NixOS/nixpkgs/issues/44426#issuecomment-629635102
  pythonOverrides = finalPy: prevPy: {
    # updates
    dask = finalPy.callPackage ./dask { };
    dask-awkward = finalPy.callPackage ./dask-awkward { };
    llvmlite = finalPy.callPackage ./llvmlite {
      llvm = final.llvm_14;
    };
    numba = finalPy.callPackage ./numba { };

    # overrides
    awkward-cpp = prevPy.awkward-cpp.overridePythonAttrs (old: rec {
      version = "15";
      src = prevPy.fetchPypi {
        pname = old.pname;
        version = version;
        sha256 = "sha256-9sgl2y25gfhSkD2VdKBwFcXVPvjkYwdy8Yx/FnBFqg0=";
      };
    });
    awkward = prevPy.awkward.overridePythonAttrs (old: rec {
      version = "2.2.0";
      src = prevPy.fetchPypi {
        pname = old.pname;
        version = version;
        sha256 = "sha256-F6hTt0s5JfERbYei0EnSMPfReRd/s2+BlBMY58VFqT0=";
      };
    });
    uproot = prevPy.uproot.overridePythonAttrs (old: rec {
      version = "5.0.7";
      src = prevPy.fetchPypi {
        pname = old.pname;
        version = version;
        sha256 = "sha256-u/GY/XpyMDS7YjeIOIXzn11CwusMqG8yZmnwqsg66uI=";
      };
    });

    # fixed version for ml model compat
    xgboost = finalPy.callPackage ./python-packages/xgboost {
      inherit (final) xgboost;
    };
    scikit-learn = finalPy.callPackage ./python-packages/scikit-learn {
      inherit (prev) gfortran glibcLocales;
    };

    # new packages
    mplhep = finalPy.callPackage ./python-packages/mplhep { };
  };
  python3 = prev.python3.override { packageOverrides = final.pythonOverrides; };
  xgboost = prev.callPackage ./xgboost { };

  # Latest root
  root = prev.callPackage ./root_6_28 {
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
