{ secrets, ... }: {
  imports = [ ../common.nix ];

  networking.hostName = "XXLPitu-Ulquiorra";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/ed9249ae-2afe-4e9c-a519-ee2fd15ceee0";
    fsType = "ext4";
    options = [ "defaults" "errors=continue" "nofail" ];
  };

  services = {
    resilio = {
      enable = true;

      secrets = secrets.services.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };

    wireguard-vpn = {
      enable = true;

      type = "client";
    };
  };
}
