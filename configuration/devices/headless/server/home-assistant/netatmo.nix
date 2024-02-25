{
  services.home-assistant.config.template = [{
    sensor = [
      {
        name = "Netatmo current temperature Bedroom";
        icon = "mdi:thermometer";
        state = "{{ state_attr('climate.bedroom', 'current_temperature') }}";
        unit_of_measurement = "°C";
      }
      {
        name = "Netatmo current temperature entrance";
        icon = "mdi:thermometer";
        state = "{{ state_attr('climate.entrance', 'current_temperature') }}";
        unit_of_measurement = "°C";
      }
      {
        name = "Netatmo current temperature living room";
        icon = "mdi:thermometer";
        state = "{{ state_attr('climate.living_room', 'current_temperature') }}";
        unit_of_measurement = "°C";
      }
    ];
  }];
}
