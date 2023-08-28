{ secrets, ... }: {
  imports = [
    ../common.nix

    ./wifi.nix
  ];

  networking.hostName = "XXLPitu-Ulquiorra";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/f7653cf6-815e-4b4a-8376-5ecbeaf35ae8";
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
