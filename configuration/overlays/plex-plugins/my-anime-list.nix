{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "my-anime-list";
  version = "unstable-2020-01-21";

  src = fetchFromGitHub {
    owner = "Fribb";
    repo = "MyAnimeList.bundle";
    rev = "6bac1c2a70b375524c6fabbd57f78ecd60c02a39";
    hash = "sha256-UYG5XxbePYArt/TYXFK99u/gRcd9w0zKPJO5mzCQ5hM=";
  };

  installPhase = ''
    mkdir -p $out/${pname}.bundle
    cp -r * $out/${pname}.bundle
  '';
}
