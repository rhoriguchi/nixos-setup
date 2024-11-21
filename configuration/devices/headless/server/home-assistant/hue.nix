{
  services.home-assistant.config.automation = [
    {
      alias = "Reset living room Signe Gradient kitchen when turned on";
      trigger = [{
        trigger = "state";
        entity_id = "light.living_room_signe_gradient_kitchen";
        from = "off";
        to = "on";
      }];
      action = [{
        action = "light.turn_on";
        target.entity_id = "light.living_room_signe_gradient_kitchen";
        data.color_temp_kelvin = 3600;
      }];
    }
    {
      alias = "Reset living room Signe Gradient window when turned on";
      trigger = [{
        trigger = "state";
        entity_id = "light.living_room_signe_gradient_window";
        from = "off";
        to = "on";
      }];
      action = [{
        action = "light.turn_on";
        target.entity_id = "light.living_room_signe_gradient_window";
        data.color_temp_kelvin = 3600;
      }];
    }
  ];
}
