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
      exportPath = "${config.services.resilio.syncPath}/Google_Photos";
    };

    resilio = {
      enable = true;

      readWriteDirs = [ "Google_Photos" "Series" "tv_time_export" ];
      secrets = (import ../../../secrets.nix).services.resilio.secrets;
      syncPath = "/srv/Sync";
    };

    tv_time_export = {
      enable = true;

      username = (import ../../../secrets.nix).services.tv_time_export.username;
      password = (import ../../../secrets.nix).services.tv_time_export.password;
      exportPath = "${config.services.resilio.syncPath}/tv_time_export";
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNyfENbLnYf0R+ATrU4zMFHsa87gWDPDH4PLwsm3Qkz67c2T6trCnxmqdIWqXPSu8CN3sHAE0hXHYxUkYNwkDFf2eIEG1BiOXGbYyktXHVjJFDcmZ8uvc1UPlp0m1qcp1g6ZUduroG12H8ltUEkaE5aZomISzalRWQ0Uh8qoWWJsgY7AQXJII+JBLLTx9q3IPYAxXFGjgCJnra8odSx2EmZL9L9A/R0LIQ+BFWjDmjCQ/xxdcMGgYJ0UiAlvour8UZFkhtg9afTTKRZAGpV8FFsp9f2lszpS+1iT9yQaGjCK/xUbuLNn5aKRaOsOlBl+a0kM9/1/O5GsfuniTjJqEr0G5P6VOF3cLDGst4Xbe0TVu9cBYMEsnxkX7Za8XR09hyqGQhpj9WbTOmQNolWjxmJRx4zfaQrlnAJAvEUUTs1y/pxviLGmeSK7nK2N91qlsqHnVWj3ZQexVAOzVGzBaKdnvRndNDeYcpbREvuLhl8itzBpG5+tYlhfJ386f3O4j4+exK9VsOzNBvP+E60bofEwI9T+1PHXO/4RAmrmGoU7UGuSXR96Z+ZgtfTJeetAiH9agTfexo7ncI8Qurzv/emsveLyOGIYut+F5K7qs9MKIvzZaIuOt3QjioGq2/TYVGrpf9TuyV3JcLMz2NPVwwLDuIzHYI5faVkF6figu79w== GitLab"
    ];
  };
}
