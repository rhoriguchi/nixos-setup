{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-mini-graph-card";
  version = "0.11.0";

  src = let
    owner = "kalkih";
    repo = "mini-graph-card";
    hash = "sha256-ujWSekx/DRS6fQzDyL79ZKGne5VHJwHBT6c88WECc1I=";
  in fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/v${version}/mini-graph-card-bundle.js";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
