{ secrets, ... }: {
  imports = [ ../common.nix ];

  networking.hostName = "XXLPitu-Nelliel";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/fca3ab27-0c04-4be7-804b-88722ffa8651";
    fsType = "ext4";
    options = [ "defaults" "errors=continue" "nofail" ];
  };

  services = {
    resilio = {
      enable = true;
      logging.enable = false;

      secrets = secrets.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };

    wireguard-network = {
      enable = true;
      type = "client";
    };
  };
}
