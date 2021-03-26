{ pkgs, ... }:
let dataDir = "/media/Data";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [ "console=ttyAMA0,115200" "console=tty1" ];

    loader = {
      grub.enable = false;

      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
  };

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-uuid/dbe57b40-53ca-5249-8160-d89e87b5aca6";
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
