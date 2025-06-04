{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-mini-graph-card";
  version = "0.13.0";

  src = let
    owner = "kalkih";
    repo = "mini-graph-card";
    tag = "v${version}";
    hash = "sha256-TYuYbzzWk8D3dx0vVXQAi8OcRey0UK7AZ5BhUL4t+r0=";
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
