{
  services.home-assistant.config.automation = [
    {
      alias = "Set bedroom nightstand lamp right brightness to night mode when sun below horizon";
      trigger = [{
        platform = "state";
        entity_id = "light.bedroom_nightstand_lamp_left";
        from = "off";
        to = "on";
      }];
      action = [{
        action = "light.turn_on";
        target.entity_id = "light.bedroom_nightstand_lamp_left";
        data.rgb_color = [ 255 157 0 ];
      }];
    }
    {
      alias = "Set bedroom nightstand lamp to night mode when sun below horizon";
      trigger = [{
        platform = "state";
        entity_id = "light.bedroom_nightstand_lamp_right";
        from = "off";
        to = "on";
      }];
      action = [{
        action = "light.turn_on";
        target.entity_id = "light.bedroom_nightstand_lamp_right";
        data.rgb_color = [ 255 157 0 ];
      }];
    }
  ];
}
