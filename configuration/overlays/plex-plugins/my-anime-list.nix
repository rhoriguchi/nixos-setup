{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "my-anime-list";
  version = "unstable-2020-01-21";

  src = fetchFromGitHub {
    owner = "Fribb";
    repo = "MyAnimeList.bundle";
    rev = "0c7b40b488fda1dd8a0a662dad99365c8d65e701";
    sha256 = "18pxsp50pfcf1kf6s0mmj8xvr1zvs3y7z3g5kdi8hc1nqr4xj26k";
  };

  installPhase = ''
    mkdir -p $out/${pname}.bundle
    cp -r * $out/${pname}.bundle
  '';
}
