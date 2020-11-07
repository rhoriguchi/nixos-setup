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

  fileSystems = {
    "${dataDir}" = {
      autoFormat = true;
      # TODO update
      device = "/dev/disk/by-uuid/0e01cf89-f498-4b5c-8df5-f6da03846b3f";
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };
  };

  virtualisation.docker.enable = true;

  networking = {
    hostName = "XXLPitu-Server";

    # TODO maybe bcmwl-kernel-source needed
    # linuxPackages.broadcom_sta

    wireless = {
      enable = true;
      interfaces = [ "wlp3s0" ];
    };
  };
}
