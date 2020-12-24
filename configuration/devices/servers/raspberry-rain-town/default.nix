{ pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-uuid/dbe57b40-53ca-5249-8160-d89e87b5aca6";
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
      checkForUpdates = false;
      syncPath = "${syncDir}";
    };
  };
}
