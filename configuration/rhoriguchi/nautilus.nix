{ config, lib, ... }: {
  environment.shellAliases.open = "nautilus";

  home-manager.users.rhoriguchi.xdg.configFile."gtk-3.0/bookmarks".text = ''
    ${lib.optionalString config.services.resilio.enable "file://${config.services.resilio.syncPath}"}
  '';
}
