{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-mini-graph-card";
  version = "0.10.0";

  src = let
    owner = "kalkih";
    repo = "mini-graph-card";
    sha256 = "04m8zk6j3hkd2q230j97b6w0f6y1bxqc4xv8ab94a0h9vfji2pl1";
  in fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/v${version}/mini-graph-card-bundle.js";
    inherit sha256;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
