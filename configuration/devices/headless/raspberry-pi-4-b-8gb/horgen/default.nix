{ pkgs, ... }: {
  imports = [ ../../default.nix ../default.nix ./hardware-configuration.nix ];

  networking = {
    hostName = "XXLPitu-Horgen";

    wireless = {
      enable = true;

      networks."NoWIFI4U".psk = (import ../../../../secrets.nix).networking.wireless.networks."NoWIFI4U".psk;
    };
  };

  services = {
    duckdns = {
      enable = true;

      token = (import ../../../../secrets.nix).services.duckdns.token;
      subdomain = "xxlpitu-horgen";
    };

    resilio = {
      enable = true;

      secrets = (import ../../../../secrets.nix).services.resilio.secrets;
      syncPath = "/media/Data/Sync";
    };
  };
}
