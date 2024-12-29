{
  services.home-assistant.config.light = [
    {
      platform = "template";
      lights.airgradient_one_display = {
        friendly_name = "AirGradient ONE display";
        value_template = "{{ (states('number.airgradient_one_display_contrast') | int) != 0 }}";
        level_template = "{{ (states('number.airgradient_one_display_contrast') | int) / 100 * 255 | round }}";
        turn_on = {
          service = "number.set_value";
          target.entity_id = "number.airgradient_one_display_contrast";
          data.value = 100;
        };
        turn_off = {
          service = "number.set_value";
          target.entity_id = "number.airgradient_one_display_contrast";
          data.value = 0;
        };
        set_level = {
          service = "number.set_value";
          target.entity_id = "number.airgradient_one_display_contrast";
          data.value = "{{ (brightness / 255 * 100) | round }}";
        };
      };
    }
    {
      platform = "group";
      name = "AirGradient ONE";
      entities = [ "light.airgradient_one_display" "light.airgradient_one_led_strip" ];
    }
  ];
}
