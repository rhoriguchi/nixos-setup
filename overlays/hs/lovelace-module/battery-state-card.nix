{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-battery-state-card";
  version = "2.1.1";

  src = let
    owner = "maxwroc";
    repo = "battery-state-card";
    hash = "sha256-y/9MHyvyaXwnhPHc9hW21pznpu4oA43drSVv644+tqg=";
  in fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/v${version}/battery-state-card.js";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
