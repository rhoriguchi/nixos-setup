{ pkgs, lib, config, ... }: {
  imports = [ ../common.nix ./hardware-configuration.nix ./home-assistant ];

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
    extraOptions = lib.concatStringsSep " " [ "--log-opt max-file=10" "--log-opt max-size=10m" ];
  };

  services = {
    duckdns = {
      enable = true;

      token = (import ../../../secrets.nix).services.duckdns.token;
      subdomains = [ "xxlpitu-hs" ];
    };

    gphotos-sync = {
      enable = true;

      projectId = (import ../../../secrets.nix).services.gphotos-sync.projectId;
      clientId = (import ../../../secrets.nix).services.gphotos-sync.clientId;
      clientSecret = (import ../../../secrets.nix).services.gphotos-sync.clientSecret;
      exportPath = "/media/Data/Sync/Google_Photos";
    };

    resilio = {
      enable = true;

      readWriteDirs = [ "Google_Photos" "Series" "tv_time_export" ];
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
      extraPlugins = [ "${pkgs.plexPlugins.my-anime-list}/${pkgs.plexPlugins.my-anime-list.pname}.bundle" ];
    };
  };

  users.users.gitlab-ci = {
    isNormalUser = true;
    group = "docker";
    hashedPassword = "*";
    openssh.authorizedKeys.keys = config.users.users.xxlpitu.openssh.authorizedKeys.keys ++ [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDws+9GVsKBTpEGCnOLRDs8meH6L2y6xJjhFWK8001JLQLyifGvbSyICTUs7ICHLHac3DeVC+S2MvItE9eQk0MweCWAiOQyjoAb029/DhJY50R44Nj1NMZ7vTwGBzYMw6tgwnV0CdC19l3wL4Y1rOMDTZB+YXy6sJrydz7nJTCaYPNQ8nA1oMKMRjrbqvy9llJMQsCrBzby8mzs/kEb3v8vKF+yuo3atOs5aj3ljUjNxzQBUunvY0QBXV6tUNm4jCPqbxy0ap3I+Q/JorFOxsObxK8IVZT8OZ4dypU10q1db/mJDuULGkTyrC46JHVOM8V0mfm9t4QMVpgRfV+iiQFL8gsl2NkvlUq65vkeTo2cDRKM7eJ9U/EXFqxNOOxNE8JVYLXrokVslB1B/iHdK+EiuKuktDbHW49Sc4aDeX9m/0qm2WeNTA41bGo6z8WiJF6F0uYB9JmbpMQar2RP4uq2S7L60uku1JiGFOQV9T1dZ+daohjWN5qxGG+ZJrNRIOSDJ2CWy+6tWcbRNXTrIfUovNozUUqQT3l4Asi92WVAdymS+Z2pmuvVd6BnK4ERMa4xD6laiZjAXpJAAUh4zoIRdzb9ICK4lS1rDhJw5M3rk1h8dw2lCRvx7TYwfA4gReYz8TXAGnVjWvlmx34TwNSWQkq8cukOvynxyiNiT2Zqkw== GitLab"
    ];
  };
}
