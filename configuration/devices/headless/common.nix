{ pkgs, lib, config, ... }:
let
  fancyMotdConfig = pkgs.writeText "fancy-motd-config" ''
    # Max width used for components in second column
    WIDTH=75

    # Services to show
    declare -A services
    services["adguardhome"]="AdGuard Home"
    services["docker"]="Docker"
    services["fancontrol"]="Fancontrol"
    services["home-assistant"]="Home Assistant"
    services["libvirtd"]="libvirt"
    services["nginx"]="NGINX"
    services["plex"]="Plex"
    services["postgresql"]="PostgreSQL"
    services["resilio"]="Resilio Sync"
    services["sshd"]="SSH"
    services["tautulli"]="Tautulli"
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
    extraGroups = [ "wheel" ] ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optional config.virtualisation.libvirtd.enable "libvirtd");
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
