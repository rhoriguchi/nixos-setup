# TODO move this to glances
{ pkgs }:
let
  pbkdf2 = pkgs.buildPythonPackage rec {
    pname = "pbkdf2";
    version = "1.3";
    name = "${pname}-${version}";

    doCheck = false;

    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0yb99rl2mbsaamj571s1mf6vgniqh23v98k4632150hjkwv9fqxc";
    };
  };
in pkgs.buildPythonPackage rec {
  pname = "wifi";
  version = "0.3.8";
  name = "${pname}-${version}";

  doCheck = false;

  src = pkgs.fetchPypi {
    inherit pname version;
    sha256 = "09kzil9jf783rg2mj7b4wnx1nm1g588wh9k89haj117aj4p0p259";
  };

  propagatedBuildInputs = [ pbkdf2 ];
}
