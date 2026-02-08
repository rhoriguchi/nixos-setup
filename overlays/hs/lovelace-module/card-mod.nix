{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-card-mod";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Dvm2i8ll7Fyuw/+7+3a50HJAmWF4PoxnyPcWExP47e8=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${finalAttrs.pname}.js
  '';
})
