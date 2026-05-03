{
  boot = {
    supportedFilesystems = [ "zfs" ];

    loader.grub.zfsSupport = true;

    zfs.forceImportRoot = true;
  };

  services.zfs = {
    expandOnBoot = "all";
    autoScrub.enable = true;
  };
}
