{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-theme-google-home";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "liri";
    repo = "lovelace-themes";
    rev = version;
    hash = "sha256-T3ZDL/L21J8OEIv4otZ2LAQPa8sgdaY8eTqWygFdY7s=";
  };

  installPhase = ''
    mkdir -p $out
    cp themes/google-home.yaml $out/${pname}.yaml
  '';
}
