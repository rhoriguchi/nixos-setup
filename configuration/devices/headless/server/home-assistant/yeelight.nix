{ ... }: {
  services.home-assistant.config = {
    yeelight.devices = {
      "yeelink-light-mono5_mibt1D55.iot" = {
        name = "Entrance window";
        model = "mono5";
      };
      "yeelink-light-mono5_mibt9166.iot" = {
        name = "Entrance hallway";
        model = "mono5";
      };
    };

    light = [{
      platform = "group";
      name = "Entrance";
      entities = [ "light.entrance_hallway" "light.entrance_window" ];
    }];
  };
}
