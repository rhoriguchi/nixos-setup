{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-card-mod";
  version = "3.0.12";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    sha256 = "18mw8bv40977bjbanqyrwim3141h1sdja95d3f1dyn0v5119h8yi";
  };

  installPhase = ''
    mkdir -p $out
    cp card-mod.js $out/${pname}.js
  '';
}
