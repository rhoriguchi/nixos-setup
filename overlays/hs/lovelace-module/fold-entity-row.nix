{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-fold-entity-row";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-fold-entity-row";
    rev = "v.${finalAttrs.version}";
    hash = "sha256-pbH2XNVrZEq3U9Kugq0X5U/CT9LNaWP9su4qWk6oob0=";
  };

  installPhase = ''
    mkdir -p $out
    cp fold-entity-row.js $out/${finalAttrs.pname}.js
  '';
})
