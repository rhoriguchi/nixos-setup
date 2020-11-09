{ glances, python3Packages, lib, stdenv }:
with lib;
glances.overrideAttrs (oldAttrs: {
  propagatedBuildInputs = with python3Packages;
    oldAttrs.propagatedBuildInputs ++ [ requests docker wifi ]
    ++ optional stdenv.isLinux pymdstat
    ++ optional stdenv.isLinux pysmart_smartx;
})
