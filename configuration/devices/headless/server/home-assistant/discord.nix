{
  services.home-assistant.config.automation = [
    {
      alias = "Stadler Form Karl low water Discord notification";
      trigger = [{
        platform = "state";
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
        platform = "state";
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
  ];
}
