{ pkgs, ... }:
let
  fancyMotdConfig = pkgs.writeText "fancy-motd-config" ''
    # Max width used for components in second column
    WIDTH=75

    # Services to show
    declare -A services
    services["adguardhome"]="AdGuard Home"
    services["docker"]="Docker"
    services["factorio"]="Factorio"
    services["fancontrol"]="Fancontrol"
    services["home-assistant"]="Home Assistant"
    services["libvirtd"]="libvirtd"
    services["nginx"]="NGINX"
    services["plex"]="Plex"
    services["postgresql"]="PostgreSQL"
    services["resilio"]="Resilio Sync"
    services["sshd"]="SSH"
    services["tautulli"]="Tautulli"
    services["zfs-zed"]="ZFS Event Daemon"
  '';
in {
  environment.shellInit = ''
    if (( EUID != 0 )) && [[ $- == *i* ]]; then
      ${pkgs.fancy-motd}/bin/motd ${fancyMotdConfig}
    fi
  '';
}
