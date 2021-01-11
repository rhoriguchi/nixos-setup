{ stdenv, fetchFromGitHub, gnome3, gettext, glib, unzip, zip }:
# TODO create pull request
# TODO does not work
# TODO don't use makefile
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-gnome-shell-clock-override";
  version = "5";

  src = fetchFromGitHub {
    owner = "stuartlangridge";
    repo = "gnome-shell-clock-override";
    rev = "v${version}";
    sha256 = "0fj4l4z842l756l5gjncjg2cfyjafm05wb41b9rny043dym0a85a";
  };

  uuid = "clock-override@gnomeshell.kryogenix.org";

  nativeBuildInputs = [ gettext glib unzip zip ];

  makeFlags = [ "PREFIX=$(out)/share/gnome-shell/extensions" ];

  meta = with stdenv.lib; {
    description = "Override the Gnome Shell clock with a new time format or text of your choice";
    # license = licenses.gpl3Only;
    # maintainers = with maintainers; [ rhoriguchi ];
    homepage = "https://github.com/stuartlangridge/gnome-shell-clock-override";
    broken = versionAtLeast gnome3.gnome-shell.version "3.18";
  };
}
