{ pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_4_19;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  swapDevices = [{
    device = "/swapfile";
    size = 1024;
  }];

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-uuid/842c1418-e4c5-4102-a214-82b124996586";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  networking = {
    hostName = "XXLPitu-Rain-Town";

    wireless = {
      enable = true;
      interfaces = [ "wlp3s0" ];
    };
  };

  duckdns = {
    enable = true;
    subdomain = "xxlpitu-rain-town";
  };

  glances.enable = true;

  rslsync = {
    enable = true;
    checkForUpdates = false;
    syncPath = "${syncDir}";
  };

  log2ram.enable = true;
}
