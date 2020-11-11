{ glances, python3Packages, lib, stdenv }:
with lib;
glances.overrideAttrs (oldAttrs: {
  # TODO add override for log file location https://glances.readthedocs.io/en/stable/config.html#logging
  # TODO fix "Missing Python Lib (No module named 'cpuinfo'), Quicklook plugin will not display CPU info"
  propagatedBuildInputs = with python3Packages;
    oldAttrs.propagatedBuildInputs ++ [ requests docker ]
    ++ optional stdenv.isLinux pymdstat;
})
