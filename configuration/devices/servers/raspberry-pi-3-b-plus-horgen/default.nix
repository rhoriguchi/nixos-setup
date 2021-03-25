{ pkgs, ... }:
let dataDir = "/media/Data";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  boot = {
    # TODO does not work pkgs.linuxPackages_rpi3;
    kernelPackages = pkgs.linuxPackages_4_19;
    kernelParams = [ "console=ttyAMA0,115200" "console=tty1" ];

    loader = {
      grub.enable = false;

      raspberryPi = {
        enable = true;
        version = 3;
      };
    };
  };

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-partuuid/0ceb323f-3733-0a4b-aacf-64c3d096bd52";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  networking = {
    hostName = "XXLPitu-Horgen";

    interfaces.eth0.useDHCP = true;
  };

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-horgen";
    };

    resilio = {
      enable = true;
      syncPath = "${dataDir}/Sync";
    };
  };
}
