{ config, ... }: {
  xdg.configFile."onedrive/config".text = ''
    sync_dir = "${config.home.homeDirectory}/Documents"
  '';
}
