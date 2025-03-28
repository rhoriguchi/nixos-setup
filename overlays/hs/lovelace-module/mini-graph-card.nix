{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-mini-graph-card";
  version = "0.12.1";

  src = let
    owner = "kalkih";
    repo = "mini-graph-card";
    tag = "v${version}";
    hash = "sha256-NfqjTTwHleXajLNlMEQgbVYfiEtsC12aCbFEuH9RGMQ=";
  in fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/${tag}/mini-graph-card-bundle.js";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
