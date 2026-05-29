{
  imports = [ ../common.nix ];

  networking = {
    hostName = "XXLPitu-Grimmjow";

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/5d4af7c3-9d62-4cc9-9e04-51d83c9bc5b4";
    fsType = "ext4";
    options = [
      "defaults"
      "errors=continue"
      "nofail"
    ];
  };

  services.custom-syncthing = {
    syncDir = "/mnt/Data/Sync";

    bandwidthLimit.upload = 15 * 1024;
  };
}
