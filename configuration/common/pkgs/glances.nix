{ glances, lib, stdenv, fetchFromGitHub, python3Packages, mach-nix }:
with lib;
let
  py3nvml = mach-nix.buildPythonPackage rec {
    pname = "py3nvml";
    version = "0.2.6";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1jyplsmj85alwzypnd1iy40hg88p6zv6aw80lamq2sqkay5nqhcq";
    };
  };

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
  # TODO add wrapper that has a couple flags allready set
  propagatedBuildInputs = oldAttrs.propagatedBuildInputs
    ++ (with python3Packages; [ docker requests ]) ++ [ py3nvml pySMART_smartx ]
    ++ optional stdenv.isLinux pymdstat;
})
