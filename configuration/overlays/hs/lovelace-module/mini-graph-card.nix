{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-mini-graph-card";
  version = "0.10.0";

  src = let
    owner = "kalkih";
    repo = "mini-graph-card";
    hash = "sha256-gV4RpdsJAkXSUmh3wnBfwRsHuFknSTAEFm3CIc38qBI=";
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
