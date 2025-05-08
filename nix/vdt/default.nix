{ stdenv
, cmake
, python
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "vdt";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "dpiparo";
    repo = "vdt";
    rev = "v${version}";
    sha256 = "sha256-wnnFby4J4k0TQcLwy4wiEdldJVzc9+yIxwESaI+KmqY=";
  };

  nativeBuildInputs = [ cmake python ];

  patches = [ ./fix_build_on_apple_silicon.patch ];
}
