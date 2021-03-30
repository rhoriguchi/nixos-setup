{ pkgs, ... }: {
  imports = [ ../../default.nix ../default.nix ./hardware-configuration.nix ];

  networking = {
    hostName = "XXLPitu-Horgen";

    wireless.enable = true;
  };

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-horgen";
    };

    resilio = {
      enable = true;
      syncPath = "/media/Data/Sync";
    };
  };
}
