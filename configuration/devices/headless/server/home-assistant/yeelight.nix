{
  services.home-assistant.config = {
    yeelight.devices = {
      "yeelink-light-mono5_mibt1D55.local" = {
        name = "Yeelight Light 1";
        model = "mono5";
      };
      "yeelink-light-mono5_mibt9166.local" = {
        name = "Yeelight Light 2";
        model = "mono5";
      };
    };

    light = [{
      platform = "group";
      name = "Yeelight Lights";
      entities = [ "light.yeelight_light_1" "light.yeelight_light_2" ];
    }];
  };
}
