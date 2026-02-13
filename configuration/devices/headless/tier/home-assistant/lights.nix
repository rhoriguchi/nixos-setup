{
  services.home-assistant.config.light = [
    # TODO HS commented
    # {
    #   platform = "group";
    #   name = "Group Lego";
    #   entities = [
    #     "light.lego_bonsai"
    #     "light.lego_chrysanthemum"
    #     "light.lego_tales_of_the_space_age"
    #   ];
    # }

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

    {
      platform = "group";
      name = "Group switch bedroom";
      entities = [ "light.bedroom_standing_lamp" ];
    }
    {
      platform = "group";
      name = "Group switch living room";
      entities = [ "light.living_room_standing_lamp" ];
    }
    {
      platform = "group";
      name = "Group switch office";
      entities = [
        "light.office_signe_gradient_wall"
        "light.office_signe_gradient_door"
      ];
    }
  ];
}
