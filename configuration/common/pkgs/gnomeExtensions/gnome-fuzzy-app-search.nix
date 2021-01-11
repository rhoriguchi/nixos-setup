{ stdenv, fetchFromGitLab, gnome3, glib }:
# TODO create pull request
# TODO does not work
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-gnome-fuzzy-app-search";
  version = "2";

  src = fetchFromGitLab {
    owner = "Czarlie";
    repo = "gnome-fuzzy-app-search";
    rev = "v${version}";
    sha256 = "07kw580l68gbxb57h2zxxhij3d09r8wf87jqzx607jlacs7gn7kv";
  };

  uuid = "gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com";

  nativeBuildInputs = [ glib ];

  makeFlags = [ "INSTALL_PATH=$(out)/share/gnome-shell/extensions" ];

  meta = with stdenv.lib; {
    description = "Fuzzy application search results for Gnome Search";
    # license = licenses.gpl3Only;
    homepage = "https://gitlab.com/Czarlie/gnome-fuzzy-app-search";
    broken = versionOlder gnome3.gnome-shell.version "3.18";
  };
}
