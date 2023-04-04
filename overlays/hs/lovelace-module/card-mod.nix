{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-card-mod";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    hash = "sha256-oFjQEY1uAYSe3+IzJTcki8MnlMliqGOmXOWho5NRKQU=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${pname}.js
  '';
}
