{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "hs-theme-google-home";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "liri";
    repo = "lovelace-themes";
    rev = version;
    sha256 = "1wx03s0d6a8604z462j1cz9na6msq9qlmmxaysymk8nvhl6q2sqx";
  };

  installPhase = ''
    mkdir -p $out
    cp themes/google-home.yaml  $out/${pname}.yaml
  '';
}
