{ stdenv, fetchFromGitHub, xorg, glib }:
# TODO does not work like intended
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-unite-shell";
  version = "43";

  src = fetchFromGitHub {
    owner = "hardpixel";
    repo = "unite-shell";
    rev = "v${version}";
    sha256 = "19l48kba1svbl024kymwn7ahv7l2pvwv9lclg1md90q01c62sklp";
  };

  uuid = "unite@hardpixel.eu";

  nativeBuildInputs = [ glib ];

  buildInputs = [ xorg.xprop ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas --strict --targetdir=${uuid}/schemas/ ${uuid}/schemas
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions
    cp -r ${uuid} $out/share/gnome-shell/extensions
    runHook postInstall
  '';
}
