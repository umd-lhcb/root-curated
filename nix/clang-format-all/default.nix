{ stdenv
, fetchFromGitHub
, clang-tools
}:

stdenv.mkDerivation rec {
  pname = "clang-format-all";
  version = "20170808";

  src = fetchFromGitHub {
    owner = "eklitzke";
    repo = pname;
    rev = "4d6ee56";
    sha256 = "EimKV6Efp0I501Sew//HFPvHHpgfn9E/pUnRJcTaHeA=";
  };

  buildInputs = [ clang-tools ];

  installPhase = ''
    mkdir -p $out/bin
    cp clang-format-all $out/bin
  '';
}
