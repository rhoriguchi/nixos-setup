{ pkgs, config, lib, ... }: {
  imports = [
    ../common.nix

    ./fancontrol
    ./home-assistant
    ./libvirtd

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "zfs" ];
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Server";

    interfaces = {
      enp5s0.useDHCP = true;
      enp6s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };
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
      subdomains = [ "xxlpitu-home" "xxlpitu-hs" ];
    };

    zfs = {
      expandOnBoot = "all";
      autoScrub.enable = true;
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
      syncPath = "/var/lib/Sync";
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

    tautulli = {
      enable = true;

      openFirewall = true;
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
