{ pkgs, ... }:
{
  virtualisation = {
    containers.registries.settings = {
      unqualified-search-registries = [ "docker.io" ];

      registry = [
        { location = "docker.io"; }
      ];
    };

    podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment = {
    systemPackages = [ pkgs.podman-compose ];

    shellAliases.docker-compose = "${pkgs.podman-compose}/bin/podman-compose";
  };
}
