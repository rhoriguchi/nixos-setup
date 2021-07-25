{ ... }: {
  services.home-assistant.config = {
    netatmo = {
      client_id = (import ../../../../secrets.nix).services.home-assistant.config.netatmo.client_id;
      client_secret = (import ../../../../secrets.nix).services.home-assistant.config.netatmo.client_secret;
    };

    homeassistant.customize."climate.netatmo_home".friendly_name = "Netatmo";

    template = [{
      sensor = [
        {
          name = "Netatmo current temperature";
          icon = "mdi:thermometer";
          state = "{{ state_attr('climate.netatmo_home', 'current_temperature') }}";
          unit_of_measurement = "°C";
        }
        {
          name = "Netatmo target temperature";
          icon = "mdi:thermometer";
          state = "{{ state_attr('climate.netatmo_home', 'temperature') }}";
          unit_of_measurement = "°C";
        }
        {
          name = "Netatmo battery";
          icon = "mdi:battery";
          state = ''
            {% set battery_level = state_attr('climate.netatmo_home', 'battery_level') %}

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
          unit_of_measurement = "%";
        }
      ];
    }];
  };
}
