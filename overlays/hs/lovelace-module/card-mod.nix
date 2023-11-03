{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-card-mod";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    hash = "sha256-JU8IZiQFWUDuUOUENLv8ffQQn6Z07PxA+674ogGNrac=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${pname}.js
  '';
}
