{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ohci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5bd5ddd3-7598-4c7a-a4f2-5b357b399b39";
    fsType = "ext4";
  };

  swapDevices = [ ];
}
