{ config, pkgs, ... }:
let homeDirectory = config.home.homeDirectory;
in {
  programs.zsh.shellAliases.open = "${pkgs.gnome.nautilus}/bin/nautilus";

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${homeDirectory}/Downloads/Browser
    file://${homeDirectory}/Sync
    file://${homeDirectory}/Sync/Git
    file://${homeDirectory}/Sync/Series
  '';
}
