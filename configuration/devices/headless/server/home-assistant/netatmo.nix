{ ... }:
let
  getBatteryState = sensorName: ''
    {% set battery_level = state_attr('${sensorName}', 'battery_level') %}

    {% if battery_level == 'full' %}
      100
    {% elif battery_level == 'high' %}
      75
    {% elif battery_level == 'medium' %}
      50
    {% elif battery_level == 'low' %}
      25
    {% elif battery_level == 'very_low' %}
      10
    {% endif %}
  '';
in {
  services.home-assistant.config = {
    netatmo = {
      client_id = (import ../../../../secrets.nix).services.home-assistant.config.netatmo.client_id;
      client_secret = (import ../../../../secrets.nix).services.home-assistant.config.netatmo.client_secret;
    };

    template = [{
      sensor = [
        {
          name = "Netatmo current temperature entrance";
          icon = "mdi:thermometer";
          state = "{{ state_attr('climate.netatmo_entrance', 'current_temperature') }}";
          unit_of_measurement = "°C";
        }
        {
          name = "Netatmo entrance battery";
          icon = "mdi:battery";
          state = getBatteryState "climate.netatmo_entrance";
          unit_of_measurement = "%";
        }
        {
          name = "Netatmo current temperature living room";
          icon = "mdi:thermometer";
          state = "{{ state_attr('climate.netatmo_living_room', 'current_temperature') }}";
          unit_of_measurement = "°C";
        }
        {
          name = "Netatmo living room battery";
          icon = "mdi:battery";
          state = getBatteryState "climate.netatmo_living_room";
          unit_of_measurement = "%";
        }
      ];
    }];
  };
}
