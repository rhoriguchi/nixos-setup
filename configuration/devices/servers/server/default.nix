{ pkgs, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "XXLPitu-Server";

    interfaces = {
      enp5s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };

    wireless.enable = true;
  };

  # TODO install https://grafana.com/docs/loki/latest/clients/docker-driver/
  virtualisation.docker.enable = true;

  system.activationScripts.turnOffWraithPrismCoolerRGB =
    "${pkgs.cm-rgb}/bin/cm-rgb-cli set logo --mode=off save";

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-home";
    };

    resilio = {
      enable = true;
      syncPath = "${syncDir}";
    };

    # TODO does not work because of recaptcha
    # mal_export = {
    #   enable = true;
    #   exportPath = "${syncDir}/mal_export";
    # };

    tv_time_export = {
      enable = true;
      exportPath = "${syncDir}/tv_time_export";
    };
  };
}
