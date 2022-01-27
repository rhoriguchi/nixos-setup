{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-fold-entity-row";
  version = "2.0.13";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-fold-entity-row";
    rev = version;
    hash = "sha256-ZwALUVjncSQKBs7n+ixUBd3bUN2vxxC5ZwlLpIbAPnY=";
  };

  installPhase = ''
    mkdir -p $out
    cp fold-entity-row.js $out/${pname}.js
  '';
}
