{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-card-mod";
  version = "3.1.5";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    hash = "sha256-BrNGWWTe+tg7yonqIk5h6qndFMt57q2vq66G9n38sUk=";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${pname}.js
  '';
}
