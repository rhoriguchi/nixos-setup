{ pkgs, ... }: {
  virtualisation = {
    containers.registries.search = [ "docker.io" ];

    podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.dnsname.enable = true;
    };
  };

  environment = {
    systemPackages = [ pkgs.podman-compose ];

    shellAliases."docker-compose" = "podman-compose";
  };
}
