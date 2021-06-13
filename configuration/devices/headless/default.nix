{ pkgs, lib, config, ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "00:00";
  };

  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 7d";
  };

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  console.keyMap = "de_CH-latin1";

  programs.zsh.shellInit = ''
    # TODO add config to add services
    ${pkgs.fancy-motd}/bin/motd
  '';

  environment.systemPackages = [ pkgs.glances pkgs.htop ];

  users.users.xxlpitu = {
    extraGroups = [ "wheel" ] ++ lib.optional config.virtualisation.docker.enable "docker";
    isNormalUser = true;
    password = (import ../../secrets.nix).users.users.xxlpitu.password;
    openssh.authorizedKeys.keys = (import ../../authorized-keys.nix).keys;
  };
}
