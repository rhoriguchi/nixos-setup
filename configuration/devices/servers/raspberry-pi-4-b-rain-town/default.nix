{ pkgs, ... }:
let dataDir = "/media/Data";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-partuuid/5a8a8b56-747d-7c47-bb99-22b87bb37f34";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  networking = {
    hostName = "XXLPitu-Rain-Town";

    interfaces.eth0.useDHCP = true;
  };

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-rain-town";
    };

    resilio = {
      enable = true;
      syncPath = "${dataDir}/Sync";
    };
  };
}
