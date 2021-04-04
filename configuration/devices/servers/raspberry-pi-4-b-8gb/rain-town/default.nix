{ pkgs, ... }: {
  imports = [ ../../default.nix ../default.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-Rain-Town";

  services = {
    duckdns = {
      enable = true;

      token = (import ../../../../secrets.nix).services.duckdns.token;
      subdomain = "xxlpitu-rain-town";
    };

    resilio = {
      enable = true;

      secrets = (import ../../../../secrets.nix).services.resilio.secrets;
      syncPath = "/media/Data/Sync";
    };
  };
}
