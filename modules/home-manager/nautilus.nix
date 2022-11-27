{ config, ... }:
let homeDirectory = config.home.homeDirectory;
in {
  programs.zsh.shellAliases.open = "nautilus";

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${homeDirectory}/Downloads/Browser
    file://${homeDirectory}/Sync
    file://${homeDirectory}/Sync/Series
  '';
}
