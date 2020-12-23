{ lib, ... }: {
  imports = [ ];

  boot = {
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "ohci_pci" "ahci" "sd_mod" ];
      kernelModules = [ ];
    };

    kernelModules = [ ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fe757b5a-00c8-4e53-826a-5e514fa2383c";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 1;

  virtualisation.virtualbox.guest.enable = true;
}
