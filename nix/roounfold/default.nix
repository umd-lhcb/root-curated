{ stdenv
, lib
, cmake
, root
, pkgconfig
, fetchFromGitLab
}:

stdenv.mkDerivation rec {
  pname = "roounfold";
  version = "2.1";

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "RooUnfold";
    repo = "RooUnfold";
    rev = "${version}";
    sha256 = "6Ezpx0A5/uo7oEY5DI4i6WYLlctxXHKdJ/CFOKajRR0=";
  };

  nativeBuildInputs = [ pkgconfig cmake ];
  buildInputs = [ root ];

  buildPhase = "make";

  installPhase = ''
    mkdir -p $out/lib
    cp libRooUnfold* $out/lib

    mkdir -p $out/include
    cp $src/src/*.h $out/include
  '';
}
