{ glances, lib, stdenv, python3Packages }:
with lib;
let
  py-cpuinfo = py-cpuinfo.overridePythonAttrs (oldAttrs: rec {
    version = "7.0.0";

    src = fetchFromGitHub {
      owner = "workhorsy";
      repo = "py-cpuinfo";
      rev = "v${version}";
      sha256 = "10qfaibyb2syiwiyv74l7d97vnmlk079qirgnw3ncklqjs0s3gbi";
    };
  });
in glances.overrideAttrs (oldAttrs: {
  # TODO add override for log file location https://glances.readthedocs.io/en/stable/config.html#logging

  propagatedBuildInputs = with python3Packages;
  # TODO remove py-cpuinfo and add the one defined in this package, don't do it globaly else pytest-benchmark needs to be rebuilt
  # TODO add https://pypi.org/project/py3nvml/#history
    oldAttrs.propagatedBuildInputs ++ [ docker pySMART_smartx requests ]
    ++ optional stdenv.isLinux pymdstat;
})
