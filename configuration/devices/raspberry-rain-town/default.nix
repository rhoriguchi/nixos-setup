{ config, pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [
    # TODO needs to be generated and replaced
    ./hardware-configuration.nix
  ];

  duckdns = {
    enable = true;
    subdomain = "xxlpitu-rain-town";
  };

  glances.enable = true;

  rslsync = {
    enable = true;
    syncPath = "${syncDir}";
  };

  fileSystems = {
    "${dataDir}" = {
      autoFormat = true;
      # TODO update
      device = "/dev/disk/by-uuid/842c1418-e4c5-4102-a214-82b124996586";
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };
  };

  networking = {
    hostName = "XXLPitu-Rain-Town";

    wireless = {
      enable = true;
      interfaces = [ "wlp3s0" ];
    };
  };
}
