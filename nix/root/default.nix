{ stdenv
, breakpointHook
, lib
, fetchurl
, makeWrapper
, cmake
, git
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
, nlohmann_json
, tbb
, vdt
, fftw
, Cocoa
, CoreSymbolication
, OpenGL
, noSplash ? false
, implicitMT ? true
, automaticSIMD ? true
}:

stdenv.mkDerivation rec {
  pname = "root";
  version = "6.24.02";

  src = fetchurl {
    url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
    sha256 = "0507e1095e279ccc7240f651d25966024325179fa85a1259b694b56723ad7c1c";
  };

  nativeBuildInputs = [ makeWrapper cmake pkg-config git ];
  buildInputs = [ ftgl gl2ps glew pcre zlib zstd libxml2 lz4 xz gsl xxHash libAfterImage giflib libjpeg libtiff libpng nlohmann_json python.pkgs.numpy fftw ]
    ++ lib.optionals (!stdenv.isDarwin) [ libX11 libXpm libXft libXext libGLU libGL expat ]
    ++ lib.optionals (stdenv.isDarwin) [ Cocoa CoreSymbolication OpenGL ]
    ++ lib.optionals (implicitMT) [ tbb ]
    ++ lib.optionals (automaticSIMD) [ vdt ]
  ;

  patches = [
    ./sw_vers.patch
    ./hist_factory.patch
  ];

  preConfigure = ''
    rm -rf builtins/*
    substituteInPlace cmake/modules/SearchInstalledSoftware.cmake \
      --replace 'set(lcgpackages ' '#set(lcgpackages '

    # Don't require textutil on macOS
    : > cmake/modules/RootCPack.cmake

    # Hardcode path to fix use with cmake
    sed -i cmake/scripts/ROOTConfig.cmake.in \
      -e 'iset(nlohmann_json_DIR "${nlohmann_json}/lib/cmake/nlohmann_json/")'

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
    "-Dbuiltin_nlohmannjson=OFF"
    "-Dbuiltin_openui5=OFF"
    "-Dalien=OFF"
    "-Dbonjour=OFF"
    "-Dcastor=OFF"
    "-Dchirp=OFF"
    "-Dclad=OFF"
    "-Ddavix=OFF"
    "-Ddcache=OFF"
    "-Dfail-on-missing=ON"
    "-Dfftw3=ON"
    "-Dfitsio=OFF"
    "-Dfortran=OFF"
    "-Dgfal=OFF"
    "-Dgviz=OFF"
    "-Dhdfs=OFF"
    "-Dhttp=ON"
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
    "-Dwebgui=OFF"
    "-Dxml=ON"
    "-Dxrootd=OFF"
  ]
  ++ lib.optional (stdenv.cc.libc != null) "-DC_INCLUDE_DIRS=${lib.getDev stdenv.cc.libc}/include"
  ++ lib.optionals stdenv.isDarwin [
    "-DOPENGL_INCLUDE_DIR=${OpenGL}/Library/Frameworks"
    "-DCMAKE_DISABLE_FIND_PACKAGE_Python2=TRUE"

    # fatal error: module map file '/nix/store/<hash>-Libsystem-osx-10.12.6/include/module.modulemap' not found
    # fatal error: could not build module '_Builtin_intrinsics'
    "-Druntime_cxxmodules=OFF"

  ]
  ++ (if implicitMT then [ "-Dimt=ON" ] else [ "-Dimt=OFF" ])
  ++ (if automaticSIMD then [ "-Dvdt=ON" ] else [ "-Dvdt=OFF" ])
  ;

  NIX_CFLAGS_COMPILE = "-O2 -march=native -mtune=native";

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
