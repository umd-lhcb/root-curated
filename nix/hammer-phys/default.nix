{ stdenv
, cmake
, boost
, libyamlcpp
, root
, python
, fetchFromGitLab
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

  nativeBuildInputs = [ cmake python.pkgs.cython ];
  buildInputs = [
    boost
    libyamlcpp
    root
    python.pkgs.numpy
    python.pkgs.matplotlib
  ];

  patches = [ ./add_missing_header.patch ./cymove_to_cython.patch ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DBUILD_SHARED_LIBS=ON"
    "-DWITH_PYTHON=ON"
    "-DWITH_ROOT=ON"
    "-DINSTALL_EXTERNAL_DEPENDENCIES=OFF"
  ];

  # Move the .so files to the lib folder so the output looks like this:
  #   lib/*.so
  # instead of:
  #   lib/Hammer/*.so
  postFixup = ''
    mv $out/lib/Hammer/* $out/lib
    rm -rf $out/lib/Hammer
  '';
}
