{
  boot.supportedFilesystems = [ "zfs" ];

  services.zfs = {
    expandOnBoot = "all";
    autoScrub.enable = true;
  };
}
