{ stdenv }:
stdenv.mkDerivation rec {
  pname = "wallpaper-icons";
  version = "1.0.0";

  src = ./wallpaper.jpg;

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/icons/hicolor/3840x2160/apps/wallpaper.jpg
  '';
}
