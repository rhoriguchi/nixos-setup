{ config, ... }:
let homeDirectory = config.home.homeDirectory;
in {
  # TODO commented since this causes issues on darwin
  # programs.zsh.shellAliases.open = "${pkgs.gnome.nautilus}/bin/nautilus";
  programs.zsh.shellAliases.open = "nautilus";

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${homeDirectory}/Downloads/Browser
    file://${homeDirectory}/Sync
    file://${homeDirectory}/Sync/Git
    file://${homeDirectory}/Sync/Series
  '';
}
