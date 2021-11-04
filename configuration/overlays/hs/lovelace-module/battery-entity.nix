{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-battery-entity";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "cbulock";
    repo = "lovelace-battery-entity";
    rev = version;
    sha256 = "1njjj9q9knqv8zh8qsp3hr04f5v1jzgxl4f5vhg4dba58j5v09p0";
  };

  installPhase = ''
    mkdir -p $out
    cp battery-entity.js $out/${pname}.js
  '';
}
