{
  services.home-assistant.config.automation = [
    {
      alias = "Stadler Form Karl low water Discord notification";
      triggers = [{
        trigger = "state";
        entity_id = "binary_sensor.stadler_form_karl_low_water";
        from = "off";
        to = "on";
      }];
      actions = [{
        action = "notify.home_assistant_bot";
        data = {
          message = "Stadler Form Karl low water";
          target = [ "1285383628527763579" ];
        };
      }];
    }
    {
      alias = "Stadler Form Karl replace filter Discord notification";
      triggers = [{
        trigger = "state";
        entity_id = "binary_sensor.stadler_form_karl_replace_filter";
        from = "off";
        to = "on";
      }];
      actions = [{
        action = "notify.home_assistant_bot";
        data = {
          message = "Stadler Form Karl replace filter";
          target = [ "1285383628527763579" ];
        };
      }];
    }
    {
      alias = "Low Battery Discord notification";
      triggers = [{
        trigger = "numeric_state";
        entity_id = [
          "sensor.bedroom_dimmer_switch_battery"
          "sensor.bedroom_h_t_gen3_battery"
          "sensor.entrance_dimmer_switch_battery"
          "sensor.entrance_h_t_gen3_battery"
          "sensor.kitchen_dimmer_switch_battery"
          "sensor.reduit_parasoll_battery"
        ];
        below = 26;
      }];
      actions = [{
        action = "notify.home_assistant_bot";
        data = {
          message = "{{ trigger.to_state.name }} has 25% or less battery";
          target = [ "1285383628527763579" ];
        };
      }];
    }
  ];
}
