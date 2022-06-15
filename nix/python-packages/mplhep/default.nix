{ stdenv, buildPythonPackage, fetchPypi, setuptools-scm, matplotlib, numpy, packaging, uhi }:

buildPythonPackage rec {
  pname = "mplhep";
  version = "0.3.25";

  src = fetchPypi {
    inherit pname version;
    sha256 = "6a2a7996fe18506bbae54756ecea403b3f7b0e23f0fc9030fe9aeba88e1e6386";
  };

  patches = [
    ./no_font_from_mplhep_data.patch
  ];

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ matplotlib numpy packaging uhi ];
  doCheck = false;
}
