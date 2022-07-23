{ pkgs, lib, config, ... }: {
  imports = [ ../../configs/doas.nix ../../configs/fancy-motd.nix ../../configs/nginx.nix ];

  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 7d";
  };

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  programs.htop.enable = true;

  environment.systemPackages = [ pkgs.file pkgs.glances ];

  users.users.xxlpitu = {
    extraGroups = [ "wheel" ] ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optional config.virtualisation.podman.enable "podman")
      ++ (lib.optionals config.virtualisation.libvirtd.enable [ "kvm" "libvirtd" ]);
    isNormalUser = true;
    password = (import ../../secrets.nix).users.users.xxlpitu.password;
    openssh.authorizedKeys.keys = import ../../authorized-keys.nix;
  };
}
