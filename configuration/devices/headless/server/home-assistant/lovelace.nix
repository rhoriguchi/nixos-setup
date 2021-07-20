{ ... }: {
  # TODO HOME-ASSISTANT use https://github.com/thomasloven/lovelace-fold-entity-row
  # - light.entrance
  #   - light.entrance_window
  #   - light.entrance_hallway
  # - sensor.unifi_wifi
  #   - sensor.unifi_wifi_default
  #   - sensor.unifi_wifi_guest
  #   - sensor.unifi_wifi_iot

  services.home-assistant.lovelaceConfig = {
    title = "Home";
    views = [{
      title = "Default";
      cards = [
        {
          type = "thermostat";
          entity = "climate.netatmo_home";
        }
        # TODO HOME-ASSISTANT use https://github.com/kalkih/mini-graph-card
        {
          type = "history-graph";
          title = "Temperature";
          hours_to_show = 24 * 7;
          refresh_interval = 60;
          entities = [
            {
              name = "Current temperature";
              entity = "sensor.netatmo_current_temperature";
            }
            {
              name = "Target temperature";
              entity = "sensor.netatmo_target_temperature";
            }
          ];
        }
        {
          type = "entities";
          title = "Lights";
          show_header_toggle = true;
          entities = [ "light.entrance" "light.entrance_window" "light.entrance_hallway" "light.living_room" ];
        }
        {
          type = "entities";
          title = "Network";
          entities = [
            {
              name = "Total";
              entity = "sensor.unifi_total";
            }
            {
              name = "Wired";
              entity = "sensor.unifi_wired";
            }
            {
              name = "WiFi";
              entity = "sensor.unifi_wifi";
            }
            {
              name = "63466727";
              entity = "sensor.unifi_wifi_default";
            }
            {
              name = "63466727-Guest";
              entity = "sensor.unifi_wifi_guest";
            }
            {
              name = "63466727-IoT";
              entity = "sensor.unifi_wifi_iot";
            }
          ];
        }
        {
          type = "entities";
          title = "Battery";
          # TODO HOME-ASSISTANT add myStrom buttons
          entities = [{
            name = "Netatmo";
            entity = "sensor.netatmo_battery";
          }];
        }
        {
          type = "entities";
          title = "Persons";
          entities = [ "person.ryan" "person.giulia" ];
        }
      ];
    }];
  };
}
