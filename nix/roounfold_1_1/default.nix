{ stdenv
, lib
, pkgconfig
, root
, fetchFromGitLab
}:

stdenv.mkDerivation rec {
  pname = "roounfold";
  version = "1.1.1";

  patches = [
    ./update_build_system.patch
    ./add_missing_header.patch
  ];

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "RooUnfold";
    repo = "RooUnfold";
    rev = "${version}";
    sha256 = "fVfNzUHKgKo1wTSpxHJZDkYjkeJPG7mxJYSdNh0fbBo=";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ root ];

  buildPhase = "make shlib";
  installPhase = ''
    mkdir -p $out/lib
    cp libRooUnfold.so $out/lib
    cp tmp/*/*.pcm $out/lib || true

    mkdir -p $out/include
    cp -r src/*.h $out/include
  '';
}
