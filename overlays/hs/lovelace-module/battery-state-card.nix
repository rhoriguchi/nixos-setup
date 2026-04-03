{ stdenv, fetchurl }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-battery-state-card";
  version = "4.2.0";

  src =
    let
      owner = "maxwroc";
      repo = "battery-state-card";
      tag = "v${finalAttrs.version}";
      hash = "sha256-MfGiIRk1oKc48W4T8xjxJ/tXjQEgMJZNLYwrp+9sEF0=";
    in
    fetchurl {
      url = "https://github.com/${owner}/${repo}/releases/download/${tag}/battery-state-card.js";
      inherit hash;
    };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${finalAttrs.pname}.js
  '';
})
