{ pkgs, ... }:
let
  # TODO HOME-ASSISTANT add all those files as packages as overlay

  batteryEntityVersion = "0.2";
  batteryEntity = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/cbulock/lovelace-battery-entity/${batteryEntityVersion}/battery-entity.js";
    sha256 = "15jmvln2qv40rpgm52ygpc8p4xr5gzgxbvvr7nranprr0vyaff17";
  };

  miniGraphCardVersion = "v0.10.0";
  miniGraphCard = pkgs.fetchurl {
    url = "https://github.com/kalkih/mini-graph-card/releases/download/${miniGraphCardVersion}/mini-graph-card-bundle.js";
    sha256 = "04m8zk6j3hkd2q230j97b6w0f6y1bxqc4xv8ab94a0h9vfji2pl1";
  };

  foldEntityRowVersion = "20.0.4";
  foldEntityRow = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/thomasloven/lovelace-fold-entity-row/${foldEntityRowVersion}/fold-entity-row.js";
    sha256 = "0bpympqgvnbddhi29qgfmnj12j1mhaqh339draxd1gwi54x2r29s";
  };

  themes = let version = "1.0.3";
  in pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/liri/lovelace-themes/${version}/themes/google-home.yaml";
    sha256 = "0f9z5qc4wjc8npc2xq8h8j1hlff6dn9ax9p0c6nbn04jidp6vpsr";
  };
in {
  systemd.tmpfiles.rules = [
    "d /run/hass 0700 nginx nginx"
    "L+ /run/hass/battery-entity.js - - - - ${batteryEntity}"
    "L+ /run/hass/fold-entity-row.js - - - - ${foldEntityRow}"
    "L+ /run/hass/mini-graph-card-bundle.js - - - - ${miniGraphCard}"
  ];

  services = {
    nginx.virtualHosts."home-assistant" = { locations."/local/" = { alias = "/run/hass/"; }; };

    home-assistant = {
      config = {
        frontend.themes = "!include ${themes}";

        automation = [{
          alias = "Set theme at startup";
          initial_state = true;
          trigger = {
            platform = "homeassistant";
            event = "start";
          };
          action = [{
            service = "frontend.set_theme";
            data.name = "Google - Light";
          }];
        }];
      };

      lovelaceConfig = {
        title = "Home";

        resources = [
          {
            url = "/local/battery-entity.js?v=${batteryEntityVersion}";
            type = "module";
          }
          {
            url = "/local/fold-entity-row.js?v=${foldEntityRowVersion}";
            type = "module";
          }
          {
            url = "/local/mini-graph-card-bundle.js?v=${miniGraphCardVersion}";
            type = "module";
          }
        ];

        views = [{
          title = "Default";
          cards = [
            {
              type = "thermostat";
              entity = "climate.netatmo_home";
            }
            {
              type = "custom:mini-graph-card";
              name = "Temperature";

              hours_to_show = 24 * 7;
              points_per_hour = 0.5;
              update_interval = 60;
              line_width = 3;
              line_color = "var(--mdc-theme-primary)";

              show = {
                icon = false;
                fill = false;
              };

              entities = [{
                name = "Current temperature";
                entity = "sensor.netatmo_current_temperature";
              }];
            }
            {
              # TODO HOME-ASSISTANT toggle is broken
              type = "entities";
              title = "Lights";
              show_header_toggle = true;
              entities = [
                {
                  type = "custom:fold-entity-row";
                  head = "light.entrance";
                  entities = [
                    {
                      name = "Hallway";
                      entity = "light.entrance_hallway";
                    }
                    {
                      name = "Window";
                      entity = "light.entrance_window";
                    }
                  ];
                }
                "light.living_room"
              ];
            }
            {
              type = "entities";
              title = "Network";
              entities = [
                {
                  name = "Total";
                  entity = "sensor.unifi_total";
                }
                { type = "divider"; }
                {
                  name = "Wired";
                  entity = "sensor.unifi_wired";
                }
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "WiFi";
                    entity = "sensor.unifi_wifi";
                  };

                  open = true;

                  entities = [
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
              ];
            }
            {
              # TODO HOME-ASSISTANT add myStrom buttons with "custom:fold-entity-row"
              type = "entities";
              title = "Battery";
              entities = [{
                type = "custom:battery-entity";
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
    };
  };
}
