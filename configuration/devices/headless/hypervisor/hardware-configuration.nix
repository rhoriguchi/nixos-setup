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
    device = "/dev/disk/by-uuid/538f3f8a-a810-41d1-a90f-2f9e6bc70e46";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/818E-B53D";
    fsType = "vfat";
  };

  fileSystems."/media/Data" = {
    device = "/dev/disk/by-uuid/b4df38ca-e5f1-4454-8f0c-178ae1400228";
    fsType = "ext4";
  };

  swapDevices = [ ];

  hardware.video.hidpi.enable = lib.mkDefault true;
}
