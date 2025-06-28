{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "hs-theme-google-home";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "liri";
    repo = "lovelace-themes";
    rev = finalAttrs.version;
    hash = "sha256-T3ZDL/L21J8OEIv4otZ2LAQPa8sgdaY8eTqWygFdY7s=";
  };

  installPhase = ''
    mkdir -p $out
    cp themes/google-home.yaml $out/${finalAttrs.pname}.yaml
  '';
})
