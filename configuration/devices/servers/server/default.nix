{ pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [
    ../default.nix

    # TODO needs to be generated and replaced
    ./hardware-configuration.nix
  ];

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-uuid/8b0f2c45-5560-4503-a72c-ff354e4fdb70";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  networking = {
    hostName = "XXLPitu-Server";

    interfaces.wlp3s0.useDHCP = true;

    # TODO maybe bcmwl-kernel-source needed
    # linuxPackages.broadcom_sta

    wireless = {
      enable = true;
      interfaces = [ "wlp3s0" ];
    };
  };

  # TODO disable wrait cooler light https://github.com/gfduszynski/cm-rgb

  virtualisation.docker.enable = true;

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-home";
    };

    resilio = {
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
  };
}
