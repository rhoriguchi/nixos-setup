{ buildPythonPackage, fetchPypi }:
buildPythonPackage rec {
  pname = "pymdstat";
  version = "0.4.2";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1addp6c94dzqwz1pwbwms0cyy1bzid4qbsfn2s3gxzb431pkrxgy";
  };
}
