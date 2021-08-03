{ pkgs, lib, config, ... }:
let
  fancyMotdConfig = pkgs.writeText "fancy-motd-config" ''
    # Max width used for components in second column
    WIDTH=75

    # Services to show
    declare -A services
    services["adguardhome"]="AdGuard Home"
    services["docker"]="Docker"
    services["duckdns.timer"]="Duck DNS (Timer)"
    services["fancontrol"]="Fancontrol"
    services["gphotos-sync.timer"]="Google Photos Sync (Timer)"
    services["home-assistant"]="Home Assistant"
    services["libvirtd"]="libvirt"
    services["nginx"]="Nginx"
    services["plex"]="Plex"
    services["postgresql"]="PostgreSQL"
    services["resilio"]="Resilio Sync"
    services["sshd"]="SSH"
    services["tv_time_export.timer"]="TV Time export (Timer)"
  '';
in {
  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 7d";
  };

  security.acme = {
    acceptTerms = true;
    email = "ryan.horiguchi@gmail.com";
  };

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  console.keyMap = "de_CH-latin1";

  programs.zsh.shellInit = ''
    if (( EUID != 0 )); then
      ${pkgs.fancy-motd}/bin/motd ${fancyMotdConfig}
    fi
  '';

  environment.systemPackages = [ pkgs.glances pkgs.htop ];

  users.users.xxlpitu = {
    extraGroups = [ "wheel" ] ++ lib.optional config.virtualisation.docker.enable "docker";
    isNormalUser = true;
    password = (import ../../secrets.nix).users.users.xxlpitu.password;
    openssh.authorizedKeys.keys = (import ../../authorized-keys.nix).keys;
  };

  system.activationScripts.create-zshrc = ''
    touch ${config.users.users.xxlpitu.home}/.zshrc
  '';

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}
