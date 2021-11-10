{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-fold-entity-row";
  version = "20.0.11";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-fold-entity-row";
    rev = version;
    sha256 = "181q88s09c46jw2jfqnz6yhbivjlg9s2kk0338nz87s43d629y1p";
  };

  installPhase = ''
    mkdir -p $out
    cp fold-entity-row.js $out/${pname}.js
  '';
}
