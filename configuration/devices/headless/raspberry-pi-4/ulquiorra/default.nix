{ secrets, ... }: {
  imports = [ ../common.nix ];

  networking.hostName = "XXLPitu-Ulquiorra";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/5d51a426-a305-4158-8cc6-ae907145df64";
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
