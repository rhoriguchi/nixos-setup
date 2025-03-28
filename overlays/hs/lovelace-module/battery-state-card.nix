{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-battery-state-card";
  version = "3.2.1";

  src = let
    owner = "maxwroc";
    repo = "battery-state-card";
    tag = "v${version}";
    hash = "sha256-BGBecR099e2wbyEtlWvPDdXTiriMdXPlNqNHGpFkZRY=";
  in fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/${tag}/battery-state-card.js";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
