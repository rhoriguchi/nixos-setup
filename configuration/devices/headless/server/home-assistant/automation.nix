{ ... }: {
  services.home-assistant.config.automation = [
    {
      alias = "Disable AdGuard protection when Withings Body+ on network";
      trigger = [{
        platform = "state";
        entity_id = [ "device_tracker.withings_body" ];
        from = "not_home";
        to = "home";
      }];
      action = [{
        service = "switch.turn_off";
        entity_id = "switch.adguard_protection";
      }];
    }
    {
      alias = "Enable AdGuard protection when Withings Body+ not on network";
      trigger = [{
        platform = "state";
        entity_id = [ "device_tracker.withings_body" ];
        from = "home";
        to = "not_home";
      }];
      action = [{
        service = "switch.turn_on";
        entity_id = "switch.adguard_protection";
      }];
    }
  ];
}
