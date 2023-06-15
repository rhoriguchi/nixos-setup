{ secrets, ... }: {
  imports = [
    ../common.nix

    ./wifi.nix
  ];

  networking.hostName = "XXLPitu-Ulquiorra";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/ed1abb92-8c16-4916-9504-af4c3fc6ec5d";
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
