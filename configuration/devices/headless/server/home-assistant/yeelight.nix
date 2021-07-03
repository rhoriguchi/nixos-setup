{ ... }: {
  services.home-assistant.config.yeelight.devices = {
    "yeelink-light-mono5_mibt1D55.iot" = {
      name = "Yeelight LED Filament Entrance Window";
      model = "mono5";
    };
    "yeelink-light-mono5_mibt9166.iot" = {
      name = "Yeelight LED Filament Entrance Hallway";
      model = "mono5";
    };
  };
}
