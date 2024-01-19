{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-battery-state-card";
  version = "3.1.3";

  src = let
    owner = "maxwroc";
    repo = "battery-state-card";
    rev = "v${version}";
    hash = "sha256-7UgbUnxvSxvH0bd3EQyC2ohojMLgjKezOYFnMI9fztU=";
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
