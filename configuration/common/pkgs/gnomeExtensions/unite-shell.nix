{ stdenv, fetchFromGitHub, xorg, glib, coreutils }:
# TODO create pull request
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-unite-shell";
  version = "44";

  src = fetchFromGitHub {
    owner = "hardpixel";
    repo = "unite-shell";
    rev = "v${version}";
    sha256 = "0nqc1q2yz4xa3fdfx45w6da1wijmdwzhdrch0mqwblgbpjr4fs9g";
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
    ${coreutils}/bin/mkdir -p $out/share/gnome-shell/extensions
    cp -r ${uuid} $out/share/gnome-shell/extensions
    runHook postInstall
  '';
}
