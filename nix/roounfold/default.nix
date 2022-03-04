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
}
