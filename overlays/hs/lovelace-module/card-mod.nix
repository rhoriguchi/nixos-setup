{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-card-mod";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w2ky3jSHRbIaTzl0b0aJq4pzuCNUV8GqYsI2U/eoGfs=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${finalAttrs.pname}.js
  '';
})
