{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-battery-state-card";
  version = "3.0.1";

  src = let
    owner = "maxwroc";
    repo = "battery-state-card";
    rev = "v${version}";
    hash = "sha256-R3fJuHkYEULEAvzdXfasBpJi2kn38vGwoxAqIveQkX4=";
  in fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/${rev}/battery-state-card.js";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
