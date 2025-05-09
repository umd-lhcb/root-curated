{ stdenv
, lib
, fetchurl
, makeWrapper
, apple-sdk
, cmake
, coreutils
, git
, fftw
, ftgl
, gl2ps
, glew
, gnugrep
, gnused
, gsl
, libAfterImage
, libGLU
, libGL
, libxcrypt
, libxml2
, lsof
, lz4
, xorg
, xz
, man
, pcre
, nlohmann_json
, pkg-config
, procps
, python3
, which
, xxHash
, zlib
, zstd
, giflib
, libjpeg
, libtiff
, libpng
, patchRcPathCsh
, patchRcPathFish
, patchRcPathPosix
, tbb
, vdt
, xrootd
, noSplash ? true
, implicitMT ? false
, automaticSIMD ? false
, useXrootd? false
}:

stdenv.mkDerivation rec {
  pname = "root";
  version = "6.24.02";

  src = fetchurl {
    url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
    sha256 = "0507e1095e279ccc7240f651d25966024325179fa85a1259b694b56723ad7c1c";
  };

  nativeBuildInputs = [
    makeWrapper
    cmake
    pkg-config
    git
  ];

  propagatedBuildInputs = [
    nlohmann_json # link interface of target "ROOT::ROOTEve", not applicable to our version?
  ];

  buildInputs =
    [
      fftw
      ftgl
      giflib
      gl2ps
      glew
      gsl
      libAfterImage
      libjpeg
      libpng
      libtiff
      libxcrypt
      libxml2
      lz4
      patchRcPathCsh
      patchRcPathFish
      patchRcPathPosix
      pcre
      python3.pkgs.numpy
      xxHash
      xz
      zlib
      zstd
    ]
    ++ lib.optionals (implicitMT) [ tbb ]
    ++ lib.optionals (automaticSIMD) [ vdt ]
    ++ lib.optionals (useXrootd) [ xrootd ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin) [ apple-sdk.privateFrameworksHook ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      libGLU
      libGL
      xorg.libX11
      xorg.libXpm
      xorg.libXft
      xorg.libXext
    ];

  patches = [
    ./sw_vers.patch
    ./hist_factory.patch
    ./fix_file_read.patch
    ./fix_glibc_noexcept.patch
    ./fix_std_modulemap.patch
    ./fix_cmake_quotation.patch
    ./fix_missing_headers.patch
  ];

  preConfigure = ''
    rm -rf builtins/*
    substituteInPlace cmake/modules/SearchInstalledSoftware.cmake \
      --replace-fail 'set(lcgpackages ' '#set(lcgpackages '

    # Don't require textutil on macOS
    : > cmake/modules/RootCPack.cmake

    # Hardcode path to fix use with cmake
    sed -i cmake/scripts/ROOTConfig.cmake.in \
      -e 'iset(nlohmann_json_DIR "${nlohmann_json}/lib/cmake/nlohmann_json/")'

    patchShebangs build/unix/
  '' + lib.optionalString noSplash ''
    substituteInPlace rootx/src/rootx.cxx --replace "gNoLogo = false" "gNoLogo = true"
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Eliminate impure reference to /System/Library/PrivateFrameworks
    substituteInPlace core/CMakeLists.txt \
      --replace-fail "-F/System/Library/PrivateFrameworks" ""
  '' + lib.optionalString
        (stdenv.hostPlatform.isDarwin && lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11")
        ''
          MACOSX_DEPLOYMENT_TARGET=10.16
        '';

  cmakeFlags = [
    "-Drpath=ON"
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_DISABLE_FIND_PACKAGE_Python2=TRUE"
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
  ]
  ++ lib.optional (stdenv.cc.libc != null) "-DC_INCLUDE_DIRS=${lib.getDev stdenv.cc.libc}/include"
  ++ lib.optional (stdenv.hostPlatform.isDarwin) "-Druntime_cxxmodules=OFF"
  ++ (if implicitMT then [ "-Dimt=ON" ] else [ "-Dimt=OFF" ])
  ++ (if automaticSIMD then [ "-Dvdt=ON" ] else [ "-Dvdt=OFF" ])
  ++ (if useXrootd then [ "-Dxrootd=ON" ] else [ "-Dxrootd=OFF" ])
  ;

  NIX_CFLAGS_COMPILE = if stdenv.hostPlatform.isLinux then "-O2 -march=native -mtune=native" else "-O2";

  postInstall = ''
    for prog in rootbrowse rootcp rooteventselector rootls rootmkdir rootmv rootprint rootrm rootslimtree; do
      wrapProgram "$out/bin/$prog" \
        --prefix PYTHONPATH : "$out/lib"
    done

    # Make ldd and sed available to the ROOT executable by prefixing PATH.
    wrapProgram "$out/bin/root" \
      --prefix PATH : "${
        lib.makeBinPath [
          gnused # sed
          stdenv.cc # c++ ld etc.
          stdenv.cc.libc # ldd
        ]
      }"

    # Patch thisroot.{sh,csh,fish}

    # The main target of `thisroot.sh` is "bash-like shells",
    # but it also need to support Bash-less POSIX shell like dash,
    # as they are mentioned in `thisroot.sh`.

    patchRcPathPosix "$out/bin/thisroot.sh" "${
      lib.makeBinPath [
        coreutils # dirname tail
        gnugrep # grep
        gnused # sed
        lsof # lsof
        man # manpath
        procps # ps
        which # which
      ]
    }"
    patchRcPathCsh "$out/bin/thisroot.csh" "${
      lib.makeBinPath [
        coreutils
        gnugrep
        gnused
        lsof # lsof
        man
        which
      ]
    }"
    patchRcPathFish "$out/bin/thisroot.fish" "${
      lib.makeBinPath [
        coreutils
        man
        which
      ]
    }"
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
