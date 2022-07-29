{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-fold-entity-row";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-fold-entity-row";
    rev = version;
    hash = "sha256-7hUkIq4Js8ingtWuQwcBNyNNxg7dFLerGY/bbguP/do=";
  };

  installPhase = ''
    mkdir -p $out
    cp fold-entity-row.js $out/${pname}.js
  '';
}
