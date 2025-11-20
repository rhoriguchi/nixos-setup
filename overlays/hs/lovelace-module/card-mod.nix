{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-card-mod";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BXyNXxCSEY0/AUD+6ggTvXPyPQYnAjkEgAVFmui6FAs=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${finalAttrs.pname}.js
  '';
})
