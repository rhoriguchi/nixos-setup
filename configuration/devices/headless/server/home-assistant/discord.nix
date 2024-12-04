{
  services.home-assistant.config.automation = [
    {
      alias = "Stadler Form Karl low water Discord notification";
      trigger = [{
        trigger = "state";
        entity_id = "binary_sensor.stadler_form_karl_low_water";
        from = "off";
        to = "on";
      }];
      action = [{
        action = "notify.home_assistant_bot";
        data = {
          message = "Stadler Form Karl low water";
          target = [ "1285383628527763579" ];
        };
      }];
    }
    {
      alias = "Stadler Form Karl replace filter Discord notification";
      trigger = [{
        trigger = "state";
        entity_id = "binary_sensor.stadler_form_karl_replace_filter";
        from = "off";
        to = "on";
      }];
      action = [{
        action = "notify.home_assistant_bot";
        data = {
          message = "Stadler Form Karl replace filter";
          target = [ "1285383628527763579" ];
        };
      }];
    }
    {
      alias = "Low Battery Discord notification";
      trigger = [{
        trigger = "numeric_state";
        entity_id = [
          "sensor.bedroom_h_t_gen3_battery"
          "sensor.entrance_h_t_gen3_battery"
          "sensor.mystrom_button_blue_battery"
          "sensor.mystrom_button_gray_battery"
          "sensor.mystrom_button_orange_battery"
          "sensor.mystrom_button_purple_battery"
          "sensor.mystrom_button_white_battery"
          "sensor.reduit_parasoll_battery"
          "sensor.valve_blue_battery"
          "sensor.valve_green_battery"
          "sensor.valve_orange_battery"
          "sensor.valve_yellow_battery"
        ];
        below = 26;
      }];
      action = [{
        action = "notify.home_assistant_bot";
        data = {
          message = "{{ trigger.to_state.name }} has 25% or less battery";
          target = [ "1285383628527763579" ];
        };
      }];
    }
  ];
}
