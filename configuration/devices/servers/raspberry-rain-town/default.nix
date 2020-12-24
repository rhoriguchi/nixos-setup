{ pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-partuuid/5a8a8b56-747d-7c47-bb99-22b87bb37f34";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  networking.hostName = "XXLPitu-Rain-Town";

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-rain-town";
    };

    resilio = {
      enable = true;
      syncPath = "${syncDir}";
    };
  };
}
