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

  # hwmon1/pwm(2|3) = cpu fans
  # hwmon1/pwm4 = case fans
  # hwmon1/pwm6 = motherboard chip fan
  # TODO figure out how to control case fans
  hardware.fancontrol = {
    enable = true;

    config = ''
      INTERVAL=1
      DEVPATH=hwmon0=devices/pci0000:00/0000:00:18.3 hwmon1=devices/platform/nct6775.656
      DEVNAME=hwmon0=k10temp hwmon1=nct6798
      FCTEMPS=hwmon1/pwm2=hwmon0/temp2_input hwmon1/pwm3=hwmon0/temp2_input
      FCFANS=hwmon1/pwm2=hwmon1/fan2_input hwmon1/pwm3=hwmon1/fan3_input
      MINTEMP=hwmon1/pwm2=65 hwmon1/pwm3=65
      MAXTEMP=hwmon1/pwm2=80 hwmon1/pwm3=80
      MINSTART=hwmon1/pwm2=20 hwmon1/pwm3=20
      MINSTOP=hwmon1/pwm2=25 hwmon1/pwm3=25
      MINPWM=hwmon1/pwm2=25 hwmon1/pwm3=25
      MAXPWM=hwmon1/pwm2=160 hwmon1/pwm3=160
    '';
  };

  # TODO install https://grafana.com/docs/loki/latest/clients/docker-driver/
  virtualisation.docker = {
    enable = true;

    logDriver = "json-file";
    extraOptions = builtins.concatStringsSep " " [
      "--log-opt max-file=10"
      "--log-opt max-size=10m"
    ];
  };

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
