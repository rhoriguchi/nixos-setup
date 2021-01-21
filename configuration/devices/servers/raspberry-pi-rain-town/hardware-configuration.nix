{ lib, pkgs, ... }: {
  imports = [ ];

  boot = {
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "usbhid" ];
      kernelModules = [ ];
    };

    kernelPackages = pkgs.linuxPackages_rpi4;

    kernelParams = [ "console=ttyAMA0,115200" "console=tty1" ];

    kernelModules = [ ];

    loader = {
      grub.enable = false;

      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];
}
