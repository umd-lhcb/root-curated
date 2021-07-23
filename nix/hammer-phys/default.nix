{ stdenv
, lib
, cmake
, pkgconfig
, boost
, libyamlcpp
, root
, python3
, fetchFromGitLab
, enablePython ? true
}:

stdenv.mkDerivation rec {
  pname = "hammer-phys";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "mpapucci";
    repo = "Hammer";
    rev = "v${version}";
    sha256 = "0ldf7h6capzbwigzqdklm9wrglrli5byhsla8x79vnq7v63xx332";
  };

  nativeBuildInputs = [ cmake pkgconfig ]
    ++ lib.optionals (enablePython) (with python3.pkgs; [ setuptools cython ])
  ;

  buildInputs = [ root ]
    ++ lib.optionals (enablePython) (with python3.pkgs; [ numpy matplotlib ])
  ;

  propagatedBuildInputs = [ boost libyamlcpp ];

  patches = [ ./add_missing_header.patch ./cymove_to_cython.patch ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DBUILD_SHARED_LIBS=ON"
    "-DWITH_PYTHON=ON"
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
    ln -s $out/lib/Hammer/* $out/lib
  '';
}
