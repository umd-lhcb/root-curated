{ stdenv
, cmake
, python
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "vdt";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "dpiparo";
    repo = "vdt";
    rev = "v${version}";
    sha256 = "gVbBHqO9qvViIvf5vTk+DZvCV2TF+8Ls6hbiGbJDjGs=";
  };

  nativeBuildInputs = [ cmake python ];
}
