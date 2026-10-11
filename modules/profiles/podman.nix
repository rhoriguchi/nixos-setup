{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" config.services.xserver.videoDrivers;

  virtualisation = {
    containers = {
      containersConf.settings.containers.log_driver = "k8s-file";

      registries.settings = {
        unqualified-search-registries = [ "docker.io" ];

        registry = [
          { location = "docker.io"; }
        ];
      };
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
