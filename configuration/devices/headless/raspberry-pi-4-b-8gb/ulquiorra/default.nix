{ secrets, ... }: {
  imports = [
    ../common.nix

    ./wifi.nix
  ];

  networking.hostName = "XXLPitu-Ulquiorra";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/eada9514-002c-4b43-875d-bac35eb033ae";
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
