{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-battery-entity";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "cbulock";
    repo = "lovelace-battery-entity";
    rev = version;
    hash = "sha256-4Cawi0RFrUYe3MUR2t+XYRdHQIbjaozgRxvbmXCSUto=";
  };

  installPhase = ''
    mkdir -p $out
    cp battery-entity.js $out/${pname}.js
  '';
}
