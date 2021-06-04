{ stdenv
, lib
, fetchurl
, makeWrapper
, cmake
, ftgl
, gl2ps
, glew
, gsl
, llvm_9
, libX11
, libXpm
, libXft
, libXext
, libGLU
, libGL
, libxml2
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
, tbb
, Cocoa
, OpenGL
, noSplash ? false
, implicitMT ? false
}:

stdenv.mkDerivation rec {
  pname = "root";
  version = "6.24.00";

  src = fetchurl {
    url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
    sha256 = "12crjzd7pzx5qpk2pb3z0rhmxlw5gsqaqzfl48qiq8c9l940b8wx";
  };

  nativeBuildInputs = [ makeWrapper cmake pkg-config llvm_9.dev ];
  buildInputs = [ ftgl gl2ps glew pcre zlib zstd llvm_9 libxml2 lz4 xz gsl xxHash libAfterImage giflib libjpeg libtiff libpng python.pkgs.numpy ]
    ++ lib.optionals (!stdenv.isDarwin) [ libX11 libXpm libXft libXext libGLU libGL ]
    ++ lib.optionals (stdenv.isDarwin) [ Cocoa OpenGL ]
    ++ lib.optionals (implicitMT) [ tbb ]
  ;

  patches = [
    ./sw_vers.patch
  ];

  preConfigure = ''
    rm -rf builtins/*
    substituteInPlace cmake/modules/SearchInstalledSoftware.cmake \
      --replace 'set(lcgpackages ' '#set(lcgpackages '

    patchShebangs build/unix/
  '' + lib.optionalString noSplash ''
    substituteInPlace rootx/src/rootx.cxx --replace "gNoLogo = false" "gNoLogo = true"
  '';

  cmakeFlags = [
    "-Drpath=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-Dalien=OFF"
    "-Dbonjour=OFF"
    "-Dbuiltin_llvm=OFF"
    "-Dcastor=OFF"
    "-Dchirp=OFF"
    "-Dclad=OFF"
    "-Ddavix=OFF"
    "-Ddcache=OFF"
    "-Dfail-on-missing=ON"
    "-Dfftw3=OFF"
    "-Dfitsio=OFF"
    "-Dfortran=OFF"
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
    "-Dsqlite=OFF"
    "-Dssl=OFF"
    "-Dvdt=OFF"
    "-Dxml=ON"
    "-Dxrootd=OFF"
    "-DCMAKE_CXX_STANDARD=17"  # Manually request C++17 standard, but NOT ROOT 7
  ]
  ++ lib.optional (stdenv.cc.libc != null) "-DC_INCLUDE_DIRS=${lib.getDev stdenv.cc.libc}/include"
  ++ lib.optionals stdenv.isDarwin [
    "-DOPENGL_INCLUDE_DIR=${OpenGL}/Library/Frameworks"
    "-DCMAKE_DISABLE_FIND_PACKAGE_Python2=TRUE"

    # fatal error: module map file '/nix/store/<hash>-Libsystem-osx-10.12.6/include/module.modulemap' not found
    # fatal error: could not build module '_Builtin_intrinsics'
    "-Druntime_cxxmodules=OFF"
  ]
  ++ lib.optional (implicitMT) "-Dimt=ON"
  ++ lib.optional (!implicitMT) "-Dimt=OFF"
  ;

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
