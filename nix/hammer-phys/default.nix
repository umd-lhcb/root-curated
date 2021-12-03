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
  pname = "hammer-phys";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "mpapucci";
    repo = "Hammer";
    rev = "v${version}";
    sha256 = "Pze1ncnzjfmlUDVP3QPV6/l/CU0PdyDL1dGB3rWYUN4=";
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
