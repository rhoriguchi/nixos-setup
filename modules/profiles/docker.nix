{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" config.services.xserver.videoDrivers;

  virtualisation.docker = {
    enable = true;

    storageDriver = "overlay2";
    logDriver = "journald";
  };

  environment.systemPackages = [ pkgs.docker-compose ];
}
