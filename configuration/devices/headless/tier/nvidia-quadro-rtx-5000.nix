{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;

    nvidia = {
      open = true;

      nvidiaPersistenced = true;
      modesetting.enable = true;
    };
  };
}
