{ stdenv
, lib
, cmake
, pkgconfig
, boost
, libyamlcpp
, root
, python3
, fetchFromGitLab
, enablePython ? false  # Python support requires a LD_LIBRARY_PATH export
}:

stdenv.mkDerivation rec {
  pname = "hammer-phys-dev";
  version = "20230422";

  src = fetchFromGitLab {
    owner = "mpapucci";
    repo = "Hammer";
    rev = "6188a2d8";
    sha256 = "ydHC234l1WhF6xfwxXpxd5gk3bQOpwmBON88DdSAHPk=";
  };

  nativeBuildInputs = [ cmake pkgconfig ]
    ++ lib.optionals (enablePython) (with python3.pkgs; [ setuptools cython ])
  ;

  buildInputs = [ root ]
    ++ lib.optionals (enablePython) (with python3.pkgs; [ numpy matplotlib ])
  ;

  propagatedBuildInputs = [ boost libyamlcpp ];

  patches = [
    ./cymove_to_cython.patch
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DBUILD_SHARED_LIBS=ON"
    "-DWITH_ROOT=ON"
    "-DINSTALL_EXTERNAL_DEPENDENCIES=OFF"
  ]
  ++ (if enablePython then [ "-DWITH_PYTHON=ON" ] else [ "-DWITH_PYTHON=OFF" ])
  ;

  # Move the .so files to the lib folder so the output looks like this:
  #   lib/*.so
  # instead of:
  #   lib/Hammer/*.so
  postFixup = ''
    mv $out/lib/Hammer/* $out/lib
    rm -rf $out/lib/Hammer
  '';
}
