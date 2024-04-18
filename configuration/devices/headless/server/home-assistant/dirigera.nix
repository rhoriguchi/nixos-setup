{
  services.home-assistant.config.automation = [
    {
      alias = "Turn Bedroom closet lights on after 1 second";
      trigger = [{
        platform = "state";
        entity_id = "light.bedroom_closet_lights";
        to = "off";
        for.seconds = 1;
      }];
      action = [{
        service = "light.turn_on";
        target.entity_id = "light.bedroom_closet_lights";
      }];
    }
    {
      alias = "Turn Reduit closet lights on when sliding door is open";
      trigger = [{
        platform = "state";
        entity_id = "binary_sensor.reduit_parasoll_contact";
        to = "on";
      }];
      action = [{
        service = "light.turn_on";
        target.entity_id = "light.reduit_closet_lights";
      }];
    }
    {
      alias = "Turn Reduit closet lights off when sliding door is closed";
      trigger = [{
        platform = "state";
        entity_id = "binary_sensor.reduit_parasoll_contact";
        to = "off";
      }];
      action = [{
        service = "light.turn_off";
        target.entity_id = "light.reduit_closet_lights";
      }];
    }
  ];
}
