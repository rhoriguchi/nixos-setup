{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-theme-google-home";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "liri";
    repo = "lovelace-themes";
    rev = version;
    hash = "sha256-HWuBDYXbolm99qrXSnHCuhpl02dBCkM+AQYp04AeoPM=";
  };

  installPhase = ''
    mkdir -p $out
    cp themes/google-home.yaml $out/${pname}.yaml
  '';
}
