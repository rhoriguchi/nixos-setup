{ ... }: {
  services.home-assistant.config.group = {
    lights = {
      name = "Lights";
      entities =
        [ "light.yeelight_led_filament_entrance_hallway" "light.yeelight_led_filament_entrance_window" "switch.mystrom_light_switch" ];
    };
    entrance_lights = {
      name = "Entrance lights";
      entities = [ "light.yeelight_led_filament_entrance_hallway" "light.yeelight_led_filament_entrance_window" ];
    };
  };
}
