{
  imports = [ ../common.nix ];

  networking.hostName = "XXLPitu-Grimmjow";

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/ea401731-f5a9-4a6b-ae7e-a07b3662132b";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  services = {
    resilio = {
      enable = true;

      secrets = (import ../../../../secrets.nix).services.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };

    wireguard-vpn = {
      enable = true;

      type = "client";
    };
  };
}