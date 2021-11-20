{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-fold-entity-row";
  version = "2.0.12";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-fold-entity-row";
    rev = version;
    sha256 = "sha256-Ib2DjNcLucWI/pt4Z+4HVtPxXAJclpFLv+WASIoiWnw=";
  };

  installPhase = ''
    mkdir -p $out
    cp fold-entity-row.js $out/${pname}.js
  '';
}
