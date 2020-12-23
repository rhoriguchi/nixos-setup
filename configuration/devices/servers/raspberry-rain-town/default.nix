{ pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-uuid/842c1418-e4c5-4102-a214-82b124996586";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  networking.hostName = "XXLPitu-Rain-Town";

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-rain-town";
    };

    rslsync = {
      enable = true;
      checkForUpdates = false;
      syncPath = "${syncDir}";
    };
  };
}
