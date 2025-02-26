{
  boot = {
    supportedFilesystems = [ "zfs" ];

    loader.grub.zfsSupport = true;
  };

  services.zfs = {
    expandOnBoot = "all";
    autoScrub.enable = true;
  };
}
