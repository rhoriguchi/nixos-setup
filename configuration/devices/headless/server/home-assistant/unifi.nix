{
  services.home-assistant.config.template = [{
    sensor = [
      {
        name = "UniFi total";
        icon = "mdi:cellphone-link";
        state =
          "{{ states.device_tracker | list | selectattr('state', 'eq', 'home') | rejectattr('attributes.is_wired', 'eq', Null) | list | length }}";
      }
      {
        name = "UniFi wired";
        icon = "mdi:cable-data";
        state =
          "{{ states.device_tracker | list | selectattr('state', 'eq', 'home') | selectattr('attributes.is_wired', 'eq', True) | list | length }}";
      }
      {
        name = "UniFi WiFi";
        icon = "mdi:wifi";
        state =
          "{{ states.device_tracker | list | selectattr('state', 'eq', 'home') | selectattr('attributes.is_wired', 'eq', False) | list | length }}";
      }
      {
        name = "UniFi WiFi default";
        icon = "mdi:wifi";
        state =
          "{{ states.device_tracker | list | selectattr('state', 'eq', 'home') | selectattr('attributes.essid', 'eq', '63466727') | list | length }}";
      }
      {
        name = "UniFi WiFi guest";
        icon = "mdi:wifi";
        state =
          "{{ states.device_tracker | list | selectattr('state', 'eq', 'home') | selectattr('attributes.essid', 'eq', '63466727-Guest') | list | length }}";
      }
      {
        name = "UniFi WiFi IoT";
        icon = "mdi:wifi";
        state =
          "{{ states.device_tracker | list | selectattr('state', 'eq', 'home') | selectattr('attributes.essid', 'eq', '63466727-IoT') | list | length }}";
      }
    ];
  }];
}
