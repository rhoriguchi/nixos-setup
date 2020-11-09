{ buildPythonPackage, fetchPypi }:
let
  pbkdf2 = buildPythonPackage rec {
    pname = "pbkdf2";
    version = "1.3";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0yb99rl2mbsaamj571s1mf6vgniqh23v98k4632150hjkwv9fqxc";
    };

    # TODO fix
    doCheck = false;
  };
in buildPythonPackage rec {
  pname = "wifi";
  version = "0.3.8";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "09kzil9jf783rg2mj7b4wnx1nm1g588wh9k89haj117aj4p0p259";
  };

  propagatedBuildInputs = [ pbkdf2 ];

  # TODO fix
  doCheck = false;
}
