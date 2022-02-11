{ config, ... }: {
  home-manager.users.rhoriguchi.xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${config.services.resilio.syncPath}
  '';
}
