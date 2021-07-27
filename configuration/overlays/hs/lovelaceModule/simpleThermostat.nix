{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-simple-thermostat";
  version = "2.4.2";

  src = let
    owner = "nervetattoo";
    repo = "simple-thermostat";
    sha256 = "0izpj9ggqhxxk1f8rmmvwn1agssmp37x9qx8j48b24bjnpapjsmb";
  in fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/v${version}/simple-thermostat.js";
    inherit sha256;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
