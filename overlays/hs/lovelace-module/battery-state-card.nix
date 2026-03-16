{ stdenv, fetchurl }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-battery-state-card";
  version = "4.0.0";

  src =
    let
      owner = "maxwroc";
      repo = "battery-state-card";
      tag = "v${finalAttrs.version}";
      hash = "sha256-RcE+FCIZDncXAkeqkJsun5JfLWPVHpsFG/nTxBGW2w8=";
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
