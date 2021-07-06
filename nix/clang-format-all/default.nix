{ stdenvNoCC
, lib
, fetchFromGitHub
, makeWrapper
, clang-tools
}:

stdenvNoCC.mkDerivation rec {
  pname = "clang-format-all";
  version = "20170808";

  src = fetchFromGitHub {
    owner = "eklitzke";
    repo = pname;
    rev = "4d6ee56";
    sha256 = "EimKV6Efp0I501Sew//HFPvHHpgfn9E/pUnRJcTaHeA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp clang-format-all $out/bin
  '';

  postFixup = ''
    wrapProgram "$out/bin/clang-format-all" \
      --prefix PATH : "${lib.makeBinPath [ clang-tools ]}"
  '';
}
