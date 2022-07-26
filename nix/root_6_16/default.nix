{ stdenv
, lib
, fetchurl
, makeWrapper
, cmake
, ftgl
, gl2ps
, glew
, gsl
, libX11
, libXpm
, libXft
, libXext
, libGLU
, libGL
, libxml2
, expat
, lz4
, xz
, pcre
, pkg-config
, python
, xxHash
, zlib
, zstd
, libAfterImage
, giflib
, libjpeg
, libtiff
, libpng
, Cocoa
, CoreSymbolication
, OpenGL
, noSplash ? false
}:

stdenv.mkDerivation rec {
  pname = "root";
  version = "6.16.00";

  src = fetchurl {
    url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
    sha256 = "2a45055c6091adaa72b977c512f84da8ef92723c30837c7e2643eecc9c5ce4d8";
  };

  nativeBuildInputs = [ makeWrapper cmake pkg-config ];
  buildInputs = [ ftgl gl2ps glew pcre zlib zstd libxml2 lz4 xz gsl xxHash libAfterImage giflib libjpeg libtiff libpng python.pkgs.numpy ]
    ++ lib.optionals (!stdenv.isDarwin) [ libX11 libXpm libXft libXext libGLU libGL expat ]
    ++ lib.optionals (stdenv.isDarwin) [ Cocoa CoreSymbolication OpenGL ]
  ;

  patches = [
    ./sw_vers.patch
    ./hist_factory.patch
    ./fix_root_config.patch
    ./fix_histo_same_binning.patch
  ];

  preConfigure = ''
    rm -rf builtins/*
    substituteInPlace cmake/modules/SearchInstalledSoftware.cmake \
      --replace 'set(lcgpackages ' '#set(lcgpackages '

    # Don't require textutil on macOS
    : > cmake/modules/RootCPack.cmake

    patchShebangs build/unix/
  '' + lib.optionalString noSplash ''
    substituteInPlace rootx/src/rootx.cxx --replace "gNoLogo = false" "gNoLogo = true"
  '' + lib.optionalString stdenv.isDarwin ''
    # Eliminate impure reference to /System/Library/PrivateFrameworks
    substituteInPlace core/CMakeLists.txt \
      --replace "-F/System/Library/PrivateFrameworks" ""
  '';

  cmakeFlags = [
    "-Drpath=ON"
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-Dbuiltin_afterimage=OFF"
    "-Dbuiltin_ftgl:BOOL=OFF"
    "-Dbuiltin_glew:BOOL=ON"
    "-Dbuiltin_unuran=OFF"
    "-Dalien=OFF"
    "-Dbonjour=OFF"
    "-Dcastor=OFF"
    "-Dchirp=OFF"
    "-Dclad=OFF"
    "-Dcxx17=ON"
    "-Ddavix=OFF"
    "-Ddcache=OFF"
    "-Dfail-on-missing=ON"
    "-Dfftw3=OFF"
    "-Dfitsio=OFF"
    "-Dfortran=OFF"
    "-Dimt=OFF"
    "-Dgfal=OFF"
    "-Dgviz=OFF"
    "-Dhdfs=OFF"
    "-Dkrb5=OFF"
    "-Dldap=OFF"
    "-Dmonalisa=OFF"
    "-Dmysql=OFF"
    "-Dodbc=OFF"
    "-Dopengl=ON"
    "-Doracle=OFF"
    "-Dpgsql=OFF"
    "-Dpythia6=OFF"
    "-Dpythia8=OFF"
    "-Drfio=OFF"
    "-Droot7=OFF"
    "-Dsqlite=OFF"
    "-Dssl=OFF"
    "-Dunuran:BOOL=OFF"
    "-Dvdt=OFF"
    "-Dxml=ON"
    "-Dxrootd=OFF"
  ]
  ++ lib.optional (stdenv.cc.libc != null) "-DC_INCLUDE_DIRS=${lib.getDev stdenv.cc.libc}/include"
  ++ lib.optionals stdenv.isDarwin [
    "-DOPENGL_INCLUDE_DIR=${OpenGL}/Library/Frameworks"
    #"-DCMAKE_DISABLE_FIND_PACKAGE_Python2=TRUE"

    # fatal error: module map file '/nix/store/<hash>-Libsystem-osx-10.12.6/include/module.modulemap' not found
    # fatal error: could not build module '_Builtin_intrinsics'
    "-Druntime_cxxmodules=OFF"
  ];

  postInstall = ''
    for prog in rootbrowse rootcp rooteventselector rootls rootmkdir rootmv rootprint rootrm rootslimtree; do
      wrapProgram "$out/bin/$prog" \
        --prefix PYTHONPATH : "$out/lib"
    done
  '';

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    homepage = "https://root.cern.ch/";
    description = "A data analysis framework";
    platforms = platforms.unix;
    maintainers = [ maintainers.veprbl ];
    license = licenses.lgpl21;
  };
}
