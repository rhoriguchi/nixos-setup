{ pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [
    # TODO needs to be generated and replaced
    ./hardware-configuration.nix
  ];

  fileSystems."${dataDir}" = {
    # TODO update
    device = "/dev/disk/by-uuid/842c1418-e4c5-4102-a214-82b124996586";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  networking = {
    hostName = "XXLPitu-Server";

    # TODO maybe bcmwl-kernel-source needed
    # linuxPackages.broadcom_sta

    wireless = {
      enable = true;
      interfaces = [ "wlp3s0" ];
    };
  };

  virtualisation.docker.enable = true;

  duckdns = {
    enable = true;
    subdomain = "xxlpitu-home";
  };

  glances.enable = true;

  rslsync = {
    enable = true;
    syncPath = "${syncDir}";
  };

  mal_export = {
    enable = true;
    exportPath = "${syncDir}/mal_export";
  };

  tv_time_export = {
    enable = true;
    exportPath = "${syncDir}/tv_time_export";
  };
}
