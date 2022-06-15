{ stdenv, buildPythonPackage, fetchPypi, numpy }:

buildPythonPackage rec {
  pname = "uhi";
  version = "0.3.1";
  format = "flit";

  src = fetchPypi {
    inherit pname version;
    sha256 = "6f1ebcadd1d0628337a30b012184325618047abc01c3539538b1655c69101d91";
  };

  propagatedBuildInputs = [ numpy ];
  doCheck = false;
}
