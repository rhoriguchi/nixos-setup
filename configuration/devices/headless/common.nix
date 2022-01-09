{ pkgs, lib, config, ... }:
let
  fancyMotdConfig = pkgs.writeText "fancy-motd-config" ''
    # Max width used for components in second column
    WIDTH=75

    # Services to show
    declare -A services
    services["adguardhome"]="AdGuard Home"
    services["audio-converter.timer"]="Audio Converter (Timer)"
    services["docker"]="Docker"
    services["duckdns.timer"]="Duck DNS (Timer)"
    services["fancontrol"]="Fancontrol"
    services["gphotos-sync.timer"]="Google Photos Sync (Timer)"
    services["home-assistant"]="Home Assistant"
    services["libvirtd"]="libvirt"
    services["nginx"]="NGINX"
    services["plex"]="Plex"
    services["postgresql"]="PostgreSQL"
    services["resilio"]="Resilio Sync"
    services["sshd"]="SSH"
    services["tautulli"]="Tautulli"
    services["tv_time_export.timer"]="TV Time export (Timer)"
    services["zfs-zed"]="ZFS Event Daemon"
  '';
in {
  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 7d";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ryan.horiguchi@gmail.com";
  };

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  console.keyMap = "de_CH-latin1";

  programs.zsh.shellInit = ''
    if (( EUID != 0 )) && [[ $- == *i* ]]; then
      ${pkgs.fancy-motd}/bin/motd ${fancyMotdConfig}
    fi
  '';

  environment.systemPackages = [ pkgs.glances pkgs.htop ];

  users.users.xxlpitu = {
    extraGroups = [ "wheel" ] ++ lib.optional config.virtualisation.docker.enable "docker";
    isNormalUser = true;
    password = (import ../../secrets.nix).users.users.xxlpitu.password;
    openssh.authorizedKeys.keys = import ../../authorized-keys.nix;
  };

  system.activationScripts.createZshrc = lib.mkIf config.programs.zsh.enable (let
    normalUsers = lib.filter (user: user.isNormalUser == true) (lib.attrValues config.users.users);
    commands = map (user: "touch ${user.home}/.zshrc") normalUsers;
  in lib.concatStringsSep "\n" commands);

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}
