{
  services.home-assistant.config.light = [{
    platform = "group";
    name = "Shelly Lights";
    entities = [ "light.shelly_light_1" "light.shelly_light_2" ];
  }];
}
