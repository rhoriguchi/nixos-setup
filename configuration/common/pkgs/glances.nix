{ glances, lib, stdenv, fetchFromGitHub, python3Packages, hddtemp }:
with lib;
let
  py-cpuinfo = python3Packages.py-cpuinfo.overridePythonAttrs (oldAttrs: rec {
    version = "7.0.0";

    src = fetchFromGitHub {
      owner = "workhorsy";
      repo = "py-cpuinfo";
      rev = "v${version}";
      sha256 = "10qfaibyb2syiwiyv74l7d97vnmlk079qirgnw3ncklqjs0s3gbi";
    };
  });

  pymdstat = python3Packages.buildPythonPackage rec {
    pname = "pymdstat";
    version = "0.4.2";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1addp6c94dzqwz1pwbwms0cyy1bzid4qbsfn2s3gxzb431pkrxgy";
    };
  };

  pySMART_smartx = python3Packages.buildPythonPackage rec {
    pname = "pySMART.smartx";
    version = "0.3.10";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "16chrzqz3ykpkikfdi71z1g31hm8pij5gs9p6fsxjd6r3awxj1zr";
    };
  };
in glances.overrideAttrs (oldAttrs: {
  propagatedBuildInputs = with python3Packages;
    [
      bottle
      docker
      future
      netifaces
      psutil
      py-cpuinfo
      pySMART_smartx
      pysnmp
      requests
      setuptools
    ] ++ optional stdenv.isLinux hddtemp ++ optional stdenv.isLinux pymdstat;
})
