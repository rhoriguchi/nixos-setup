{ stdenv, fetchFromGitLab, gettext, glib, meson, ninja, xdg-desktop-portal-gtk
}:
# TODO does not work like intended
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-desktop-icons";
  version = "20.04.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    group = "World";
    owner = "ShellExtensions";
    repo = "desktop-icons";
    rev = version;
    sha256 = "0502g9fwl23mzb636y29jd57j3wmpmhj5m04bn6zm134y65yk8qn";
  };

  uuid = "desktop-icons@csoriano";

  nativeBuildInputs = [ gettext glib meson ninja ];

  buildInputs = [ xdg-desktop-portal-gtk ];

  mesonFlags =
    [ "--localedir=$out/share/gnome-shell/extensions/${uuid}/locale" ];
}
