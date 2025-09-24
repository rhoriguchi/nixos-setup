{ config, pkgs, ... }:
{
  virtualisation = {
    containers.registries.search = [ "docker.io" ];

    podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment = {
    systemPackages = [ pkgs.podman-compose ];

    shellAliases.docker-compose = "${config.virtualisation.podman.package}/bin/podman-compose";
  };
}
