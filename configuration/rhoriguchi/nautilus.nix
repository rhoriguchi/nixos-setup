{ config, lib, ... }: {
  environment.shellAliases.open = "nautilus";

  home-manager.users.rhoriguchi.xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${config.users.users.rhoriguchi.home}/Downloads/Browser
    ${lib.optionalString config.services.resilio.enable "file://${config.services.resilio.syncPath}"}
  '';
}
