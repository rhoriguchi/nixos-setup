{ ... }: {
  # TODO HOME-ASSISTANT add buttons

  services.home-assistant.config = {
    switch = [{
      platform = "mystrom";
      name = "myStrom Light Switch";
      host = "myStrom-Switch-8A0F50.iot";
    }];

    homeassistant.customize."switch.mystrom_light_switch".icon = "mdi:lightbulb";

    template = [{
      sensor = [{
        name = "myStrom Light Switch current power";
        unique_id = "myStrom_current_power";
        icon = "mdi:flash";
        state = "{{ state_attr('switch.mystrom_light_switch', 'current_power_w') }}";
      }];
    }];
  };
}
