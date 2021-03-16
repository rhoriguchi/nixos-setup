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
      # without PCI-E GPU
      enp4s0.useDHCP = true;
      wlp3s0.useDHCP = true;

      # with PCI-E GPU
      enp5s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };

    wireless.enable = true;
  };

  # TODO install https://grafana.com/docs/loki/latest/clients/docker-driver/
  virtualisation.docker.enable = true;

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
