{ stdenv, buildPythonPackage, fetchPypi, setuptools-scm, matplotlib, numpy, packaging, uhi }:

buildPythonPackage rec {
  pname = "mplhep";
  version = "0.3.28";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-/7nfjIdlYoouDOI1vXdr9BSml5gpE0gad7ONAUmOCiE=";
  };

  patches = [
    ./no_font_from_mplhep_data.patch
  ];

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ matplotlib numpy packaging uhi ];
  doCheck = false;
}
