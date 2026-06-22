{
  services.home-assistant.config.light = [
    {
      platform = "group";
      name = "Group Bedroom";
      entities = [
        "light.bedroom_nightstand_lamp_left"
        "light.bedroom_nightstand_lamp_right"
        "light.bedroom_standing_lamp"
      ];
    }
    {
      platform = "group";
      name = "Group Dining room";
      entities = [ "light.dining_room_standing_lamp" ];
    }
    {
      platform = "group";
      name = "Group Guest room";
      entities = [ "light.guest_room_closet_lights" ];
    }
    {
      platform = "group";
      name = "Group Living room";
      entities = [
        "light.living_room_standing_lamp"
        "light.living_room_table_lamp"
      ];
    }
    {
      platform = "group";
      name = "Group Office";
      entities = [
        "light.office_signe_gradient_wall"
        "light.office_signe_gradient_door"
      ];
    }
  ];
}
