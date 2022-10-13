let
  createFormatFunction = sensor: ''
    {% set value = states('${sensor}') | float %}
    {% if value < 0 %}
      0
    {% else %}
      {{ (value * 1000 / 1024 / 1024) | round(3) }}
    {% endif %}
  '';
in {
  services.home-assistant.config.template = [{
    sensor = [
      {
        name = "Deluge Status formatted";
        icon = "mdi:file-arrow-up-down";
        state = ''
          {% if is_state('sensor.deluge_status', 'idle') %}
            Idle
          {% else %}
            {{ states('sensor.deluge_status') }}
          {% endif %}
        '';
      }
      {
        name = "Deluge Down speed formatted";
        icon = "mdi:file-download";
        state = createFormatFunction "sensor.deluge_down_speed";
        unit_of_measurement = "MB/s";
      }
      {
        name = "Deluge Up speed formatted";
        icon = "mdi:file-upload";
        state = createFormatFunction "sensor.deluge_up_speed";
        unit_of_measurement = "MB/s";
      }
    ];
  }];
}
