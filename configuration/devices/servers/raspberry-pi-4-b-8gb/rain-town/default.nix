{ pkgs, ... }: {
  imports = [ ../../default.nix ../default.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-Rain-Town";

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-rain-town";
    };

    resilio = {
      enable = true;
      syncPath = "/media/Data/Sync";
    };
  };
}
