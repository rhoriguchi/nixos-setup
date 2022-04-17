{ pkgs, ... }: {
  virtualisation = {
    containers.registries.search = [ "docker.io" ];

    podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };

  environment.systemPackages = [ pkgs.docker-compose ];
}
