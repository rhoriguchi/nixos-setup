{ stdenv, fetchFromGitHub, gnome3, gettext, glib, unzip, zip }:
# TODO create pull request
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-clock-override";
  version = "5";

  src = fetchFromGitHub {
    owner = "stuartlangridge";
    repo = "gnome-shell-clock-override";
    rev = "v${version}";
    sha256 = "0fj4l4z842l756l5gjncjg2cfyjafm05wb41b9rny043dym0a85a";
  };

  uuid = "clock-override@gnomeshell.kryogenix.org";

  nativeBuildInputs = [ gettext glib unzip zip ];

  preBuild = "sed -i '/gnome-shell-extension-tool/d' Makefile";

  makeFlags = [ "PREFIX=$(out)/share/gnome-shell/extensions" ];

  meta = with stdenv.lib; {
    description = "Override the Gnome Shell clock with a new time format or text of your choice";
    license = licenses.mit;
    homepage = "https://github.com/stuartlangridge/gnome-shell-clock-override";
    broken = versionOlder gnome3.gnome-shell.version "3.18";
  };
}
