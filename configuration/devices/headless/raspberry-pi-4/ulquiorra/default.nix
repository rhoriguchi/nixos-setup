{ secrets, ... }: {
  imports = [ ../common.nix ];

  networking.hostName = "XXLPitu-Ulquiorra";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/44064fb4-2d1e-4df4-b477-9cf5f8194fb4";
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
