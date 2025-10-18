{
  # TODO HS notify firmware update

  # TODO HS get entity id automatically also check if power connected
  services.home-assistant.config.automation = [
    {
      alias = "Low Battery Discord notification";
      triggers = [
        {
          trigger = "numeric_state";
          entity_id = [
            "sensor.bedroom_dimmer_switch_battery"
            "sensor.bedroom_h_t_gen3_battery"
            "sensor.living_room_h_t_gen3_battery"
            "sensor.guest_room_h_t_gen3_battery"
            "sensor.living_room_dimmer_switch_battery"
            "sensor.office_dimmer_switch_battery"
          ];
          below = 26;
        }
      ];
      actions = [
        {
          action = "notify.home_assistant_bot";
          data = {
            message = "{{ trigger.to_state.name }} has 25% or less battery";
            target = [ "1285383628527763579" ];
          };
        }
      ];
    }
  ];
}
