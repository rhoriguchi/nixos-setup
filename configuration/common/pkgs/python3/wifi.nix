{ pkgs }:
(pkgs.buildPythonPackage rec {
  pname = "wifi";
  version = "0.3.8";
  name = "${pname}-${version}";

  doCheck = false;

  src = pkgs.fetchPypi {
    inherit pname version;
    sha256 = "09kzil9jf783rg2mj7b4wnx1nm1g588wh9k89haj117aj4p0p259";
  };
})
