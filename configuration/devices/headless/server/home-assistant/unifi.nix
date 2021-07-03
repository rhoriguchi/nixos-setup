{ ... }: {
  services.home-assistant.config.template = [{
    unique_id = "unifi";
    sensor = [
      {
        name = "UniFi";
        unique_id = "all";
        icon = "mdi:cellphone-link";
        state = "{{ states.device_tracker | list | length }}";
      }
      {
        name = "UniFi wired";
        unique_id = "wired";
        icon = "mdi:cellphone-link";
        state = "{{ states.device_tracker | list | selectattr('attributes.is_wired', 'eq', True) | list | length }}";
      }
      {
        name = "UniFi WiFi";
        unique_id = "wifi";
        icon = "mdi:cellphone-link";
        state = "{{ states.device_tracker | list | selectattr('attributes.is_wired', 'eq', False) | list | length }}";
      }
      {
        name = "UniFi 63466727";
        unique_id = "wifi_default";
        icon = "mdi:cellphone-link";
        state = "{{ states.device_tracker | list | selectattr('attributes.essid', 'eq', '63466727') | list | length }}";
      }
      {
        name = "UniFi 63466727-Guest";
        unique_id = "wifi_guest";
        icon = "mdi:cellphone-link";
        state = "{{ states.device_tracker | list | selectattr('attributes.essid', 'eq', '63466727-Guest') | list | length }}";
      }
      {
        name = "UniFi 63466727-IoT";
        unique_id = "wifi_iot";
        icon = "mdi:cellphone-link";
        state = "{{ states.device_tracker | list | selectattr('attributes.essid', 'eq', '63466727-IoT') | list | length }}";
      }
    ];
  }];
}
