{ pkgs, ... }: {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelModules = [ "k10temp" "nct6775" ];
  };

  networking = {
    hostName = "XXLPitu-Server";

    interfaces = {
      # without PCI-E GPU
      enp4s0.useDHCP = true; # Ethernet

      # with PCI-E GPU
      enp5s0.useDHCP = true; # Ethernet
    };
  };

  hardware.fancontrol = {
    enable = true;

    # grep -H . /sys/class/hwmon/hwmon*/name
    # grep -H . /sys/class/hwmon/hwmon*/temp*_label
    # grep -H . /sys/class/hwmon/hwmon*/fan*_input

    # hwmon2/pwm(2|3) = cpu fans
    # hwmon2/pwm(1|4) = case fans
    # hwmon2/pwm6 = motherboard chip fan

    # hwmon1/temp1_label = Tctl
    # hwmon2/temp1_label = SYSTIN
    # hwmon2/temp6_label = AUXTIN3

    config = ''
      INTERVAL=1
      DEVPATH=hwmon1=devices/pci0000:00/0000:00:18.3 hwmon2=devices/platform/nct6775.656
      DEVNAME=hwmon1=k10temp hwmon2=nct6798
      FCTEMPS=hwmon2/pwm1=hwmon2/temp6_input hwmon2/pwm2=hwmon2/temp1_input hwmon2/pwm3=hwmon2/temp1_input hwmon2/pwm4=hwmon2/temp6_input hwmon2/pwm6=hwmon2/temp1_input
      FCFANS=hwmon2/pwm1=hwmon2/fan1_input hwmon2/pwm2=hwmon2/fan2_input hwmon2/pwm3=hwmon2/fan3_input hwmon2/pwm4=hwmon2/fan4_input hwmon2/pwm6=hwmon2/fan6_input
      MINTEMP=hwmon2/pwm1=40 hwmon2/pwm2=65 hwmon2/pwm3=65 hwmon2/pwm4=40 hwmon2/pwm6=65
      MAXTEMP=hwmon2/pwm1=60 hwmon2/pwm2=80 hwmon2/pwm3=80 hwmon2/pwm4=60 hwmon2/pwm6=80
      MINSTART=hwmon2/pwm1=20 hwmon2/pwm2=20 hwmon2/pwm3=20 hwmon2/pwm4=20 hwmon2/pwm6=60
      MINSTOP=hwmon2/pwm1=25 hwmon2/pwm2=25 hwmon2/pwm3=25 hwmon2/pwm4=25 hwmon2/pwm6=55
      MINPWM=hwmon2/pwm1=25 hwmon2/pwm2=25 hwmon2/pwm3=25 hwmon2/pwm4=25 hwmon2/pwm6=55
      MAXPWM=hwmon2/pwm1=160 hwmon2/pwm2=160 hwmon2/pwm3=160 hwmon2/pwm4=160 hwmon2/pwm6=160
    '';
  };

  virtualisation.docker = {
    enable = true;

    logDriver = "json-file";
    extraOptions = builtins.concatStringsSep " " [ "--log-opt max-file=10" "--log-opt max-size=10m" ];
  };

  services = {
    duckdns = {
      enable = true;

      token = (import ../../../secrets.nix).services.duckdns.token;
      subdomain = "xxlpitu-server";
    };

    resilio = {
      enable = true;

      readWriteDirs = [ "Series" "tv_time_export" ];
      secrets = (import ../../../secrets.nix).services.resilio.secrets;
      syncPath = "/media/Data/Sync";
    };

    tv_time_export = {
      enable = true;

      username = (import ../../../secrets.nix).services.tv_time_export.username;
      password = (import ../../../secrets.nix).services.tv_time_export.password;
      exportPath = "/media/Data/Sync/tv_time_export";
    };

    plex = {
      enable = true;

      openFirewall = true;
      extraPlugins = [ "${pkgs.plexPlugins.myanimelist}/${pkgs.plexPlugins.myanimelist.pname}.bundle" ];
    };
  };
}
