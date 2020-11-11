{ glances, python3Packages, lib, stdenv }:
let
  pymdstat = python3Packages.buildPythonPackage rec {
    pname = "pymdstat";
    version = "0.4.2";
    name = "${pname}-${version}";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1addp6c94dzqwz1pwbwms0cyy1bzid4qbsfn2s3gxzb431pkrxgy";
    };
  };
in with lib;
glances.overrideAttrs (oldAttrs: {
  # TODO add override for log file location https://glances.readthedocs.io/en/stable/config.html#logging
  # TODO fix "Missing Python Lib (No module named 'cpuinfo'), Quicklook plugin will not display CPU info"
  propagatedBuildInputs = with python3Packages;
    oldAttrs.propagatedBuildInputs ++ [ requests docker ]
    ++ optional stdenv.isLinux pymdstat;
})
