# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/81a78608-5980-447e-82bc-5be669577d0a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EA22-EA13";
    fsType = "vfat";
  };

  fileSystems."/mnt/Data/Backup" = {
    device = "data/backup";
    fsType = "zfs";
  };

  fileSystems."/mnt/Data/Deluge" = {
    device = "data/deluge";
    fsType = "zfs";
  };

  fileSystems."/mnt/Data/Snapshots" = {
    device = "data/snapshots";
    fsType = "zfs";
  };

  fileSystems."/mnt/Data/Sync" = {
    device = "data/sync";
    fsType = "zfs";
  };

  swapDevices = [ ];

  hardware.video.hidpi.enable = lib.mkDefault true;
}
