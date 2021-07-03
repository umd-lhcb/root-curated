{ stdenv
, lib
, fetchFromGitHub
, cmake
, pcre
, pkgconfig
, libX11
, libXpm
, libXft
, libXext
, libGLU
, libGL
, zlib
, libxml2
, lz4
, lzma
, gsl_1
, xxHash
, Cocoa
, OpenGL
, noSplash ? false
}:

stdenv.mkDerivation rec {
  pname = "root";
  version = "5.34.38";

  src = fetchFromGitHub {
    owner = "root-project";
    repo = pname;
    rev = "v" + lib.concatStringsSep "-" (lib.splitString "." version);
    sha256 = "1lyz4b2raql3fw4l1k05d5lsmidp3nrqr6x0ckafqllilaah6n0k";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ cmake pcre zlib libxml2 lz4 lzma gsl_1 xxHash ]
    ++ lib.optionals (!stdenv.isDarwin) [ libX11 libXpm libXft libXext libGLU libGL ]
    ++ lib.optionals (stdenv.isDarwin) [ Cocoa OpenGL ]
  ;

  patches = [
    # various fixes to ROOT build system
    ./sw_vers_root5.patch

    # prevents rootcint from looking in /usr/includes and such
    ./purify_include_paths_root5.patch

    # disable dictionary generation for stuff that includes libc headers
    # our glibc requires a modern compiler
    ./disable_libc_dicts_root5.patch

    ./hist_factory.patch
  ];

  preConfigure = ''
    patchShebangs build/unix/
    ln -s ${lib.getDev stdenv.cc.libc}/include/AvailabilityMacros.h cint/cint/include/
  ''
  # Fix CINTSYSDIR for "build" version of rootcint
  # This is probably a bug that breaks out-of-source builds
  + ''
    substituteInPlace cint/cint/src/loadfile.cxx\
      --replace 'env = "cint";' 'env = "'`pwd`'/cint";'
  '' + lib.optionalString noSplash ''
    substituteInPlace rootx/src/rootx.cxx --replace "gNoLogo = false" "gNoLogo = true"
  '';

  cmakeFlags = [
    "-Drpath=ON"
    "-DCMAKE_CXX_STANDARD=11"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-Dalien=OFF"
    "-Dbonjour=OFF"
    "-Dcastor=OFF"
    "-Dchirp=OFF"
    "-Ddavix=OFF"
    "-Ddcache=OFF"
    "-Dfftw3=OFF"
    "-Dfitsio=OFF"
    "-Dfortran=OFF"
    "-Dgfal=OFF"
    "-Dgsl_shared=ON"
    "-Dgviz=OFF"
    "-Dhdfs=OFF"
    "-Dkrb5=OFF"
    "-Dldap=OFF"
    "-Dmathmore=ON"
    "-Dmonalisa=OFF"
    "-Dmysql=OFF"
    "-Dodbc=OFF"
    "-Dopengl=ON"
    "-Doracle=OFF"
    "-Dpgsql=OFF"
    "-Dpythia6=OFF"
    "-Dpythia8=OFF"
    "-Dpython=OFF"
    "-Drfio=OFF"
    "-Dsqlite=OFF"
    "-Dssl=OFF"
    "-Dxml=ON"
    "-Dxrootd=OFF"
  ]
  ++ lib.optional stdenv.isDarwin "-DOPENGL_INCLUDE_DIR=${OpenGL}/Library/Frameworks";

  enableParallelBuilding = true;

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    homepage = "https://root.cern.ch/";
    description = "A data analysis framework";
    platforms = platforms.unix;
    # maintainers = with maintainers; [ veprbl ];  # This is a local port, and is not maintained by Dmitry!
    license = licenses.lgpl21;
  };
}
