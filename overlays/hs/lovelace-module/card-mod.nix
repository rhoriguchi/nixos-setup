{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-card-mod";
  version = "3.4.4";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CG0zOD1TluZiFqRkmr/ZRQMRAY/5OhqjsD291zOr2/c=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${finalAttrs.pname}.js
  '';
})
