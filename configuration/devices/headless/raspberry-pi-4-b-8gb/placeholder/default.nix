{
  imports = [ ../common.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-PLACEHOLDER";

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
