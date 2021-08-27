{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-lovelace-module-fold-entity-row";
  version = "20.0.4";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-fold-entity-row";
    rev = version;
    sha256 = "0j50j78ws9cl29pvg5782ykvrsv69mnnpmpj99qjdcfhhqgi2w5j";
  };

  installPhase = ''
    mkdir -p $out
    cp fold-entity-row.js $out/${pname}.js
  '';
}
