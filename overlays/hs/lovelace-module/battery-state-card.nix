{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-battery-state-card";
  version = "3.2.0";

  src = let
    owner = "maxwroc";
    repo = "battery-state-card";
    rev = "v${version}";
    hash = "sha256-ydUgaUexlCnyTHKN3uR7fT7MzUqSvnx8RkMHV23aY/E=";
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
