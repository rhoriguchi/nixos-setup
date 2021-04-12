{ config, ... }: {
  home-manager.users.rhoriguchi.xdg.configFile."onedrive/config".text = ''
    sync_dir = "${config.users.users.rhoriguchi.home}/Documents"
  '';
}
