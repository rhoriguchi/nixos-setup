{
  services.home-assistant.config.light = [
    {
      platform = "group";
      name = "REMOVE Yeelight Lights";
      entities = [ "light.remove_yeelight_light_1" "light.remove_yeelight_light_2" ];
    }

    {
      platform = "group";
      name = "Group Bedroom";
      entities = [ "light.bedroom_lamp" ];
    }
    {
      platform = "group";
      name = "Group Entrance";
      entities = [ "light.entrance_ceiling_lamp" "light.entrance_sideboard_lamp" "light.remove_yeelight_lights" ];
    }
    {
      platform = "group";
      name = "Group Hallway";
      entities = [ "light.hallway_lamp" ];
    }
    {
      platform = "group";
      name = "Group Living room";
      entities =
        [ "light.signe_gradient_floor" "light.living_room_lamp" "light.living_room_table_lamp" "light.remove_mystrom_light_switch_2" ];
    }
  ];
}
