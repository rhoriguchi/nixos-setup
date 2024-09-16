{
  services.home-assistant.config.light = [
    {
      platform = "group";
      name = "Group Lego";
      entities = [ "light.lego_bonsai" ];
    }

    {
      platform = "group";
      name = "Group Bedroom";
      entities = [ "light.bedroom_nightstand_lamp_left" "light.bedroom_nightstand_lamp_right" "light.bedroom_standing_lamp" ];
    }
    {
      platform = "group";
      name = "Group Entrance";
      entities = [ "light.entrance_lamp" "light.entrance_sideboard_lamp" "light.remove_yeelight_lights" ];
    }
    {
      platform = "group";
      name = "Group Hallway";
      entities = [ "light.hallway_lamp" ];
    }
    {
      platform = "group";
      name = "Group Kitchen";
      entities = [ "light.kitchen_standing_lamp" ];
    }
    {
      platform = "group";
      name = "Group Living room";
      entities = [
        "light.living_room_signe_gradient_kitchen"
        "light.living_room_signe_gradient_window"
        "light.living_room_standing_lamp"
        "light.living_room_table_lamp"
      ];
    }
    {
      platform = "group";
      name = "Group Reduit";
      entities = [ "light.reduit_closet_lights" ];
    }
  ];
}
