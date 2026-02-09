{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-lovelace-module-card-mod";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-16aA9VaSuWZ1i9UBGp9vb7N1H5vfcLOiqppjPoqphM0=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${finalAttrs.pname}.js
  '';
})
