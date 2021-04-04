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
    hostName = "XXLPitu-Home";

    interfaces = {
      # without PCI-E GPU
      enp4s0.useDHCP = true;
      wlp3s0.useDHCP = true;

      # with PCI-E GPU
      enp5s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };

    wireless = {
      enable = true;
      networks."47555974".psk = (import ../../../secrets.nix).networking.wireless.networks."47555974".psk;
    };
  };

  hardware.fancontrol = {
    enable = true;

    # hwmon1/pwm(2|3) = cpu fans
    # hwmon1/pwm(1|4) = case fans
    # hwmon1/pwm6 = motherboard chip fan

    config = ''
      INTERVAL=1
      DEVPATH=hwmon0=devices/pci0000:00/0000:00:18.3 hwmon1=devices/platform/nct6775.656
      DEVNAME=hwmon0=k10temp hwmon1=nct6798
      FCTEMPS=hwmon1/pwm1=hwmon1/temp6_input hwmon1/pwm2=hwmon0/temp2_input hwmon1/pwm3=hwmon0/temp2_input hwmon1/pwm4=hwmon1/temp6_input hwmon1/pwm6=hwmon1/temp1_input
      FCFANS=hwmon1/pwm1=hwmon1/fan1_input hwmon1/pwm2=hwmon1/fan2_input hwmon1/pwm3=hwmon1/fan3_input hwmon1/pwm4=hwmon1/fan4_input hwmon1/pwm6=hwmon1/fan6_input
      MINTEMP=hwmon1/pwm1=40 hwmon1/pwm2=65 hwmon1/pwm3=65 hwmon4/pwm4=40 hwmon1/pwm6=65
      MAXTEMP=hwmon1/pwm1=60 hwmon1/pwm2=80 hwmon1/pwm3=80 hwmon1/pwm4=60 hwmon1/pwm6=80
      MINSTART=hwmon1/pwm1=20 hwmon1/pwm2=20 hwmon1/pwm3=20 hwmon1/pwm4=20 hwmon1/pwm6=60
      MINSTOP=hwmon1/pwm1=25 hwmon1/pwm2=25 hwmon1/pwm3=25 hwmon1/pwm4=25 hwmon1/pwm6=55
      MINPWM=hwmon1/pwm1=25 hwmon1/pwm2=25 hwmon1/pwm3=25 hwmon1/pwm4=25 hwmon1/pwm6=55
      MAXPWM=hwmon1/pwm1=160 hwmon1/pwm2=160 hwmon1/pwm3=160 hwmon1/pwm4=160 hwmon1/pwm6=160
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
      subdomain = "xxlpitu-home";
    };

    resilio = {
      enable = true;

      secrets = (import ../../../secrets.nix).services.resilio.secrets;
      syncPath = "/media/Data/Sync";
    };

    tv_time_export = {
      enable = true;

      username = (import ../../../secrets.nix).services.tv_time_export.username;
      password = (import ../../../secrets.nix).services.tv_time_export.password;
      exportPath = "/media/Data/Sync/tv_time_export";
    };
  };
}
