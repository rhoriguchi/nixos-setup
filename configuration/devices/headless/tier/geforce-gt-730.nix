{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

      nvidiaPersistenced = true;
      modesetting.enable = true;
    };
  };
}
