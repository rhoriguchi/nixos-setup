{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-card-mod";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    hash = "sha256-zCPq1yDtXY9XpTxpxTwyqpZOFYDsI07b12eB2SukSP0=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${pname}.js
  '';
}
