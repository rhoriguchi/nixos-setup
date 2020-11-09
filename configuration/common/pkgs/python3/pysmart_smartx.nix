{ buildPythonPackage, fetchPypi }:
buildPythonPackage rec {
  pname = "pySMART.smartx";
  version = "0.3.10";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "16chrzqz3ykpkikfdi71z1g31hm8pij5gs9p6fsxjd6r3awxj1zr";
  };
}
