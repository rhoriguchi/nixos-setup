{ pkgs, ... }:
let
  lovelaceModules = [
    pkgs.hs.lovelaceModule.batteryEntity
    pkgs.hs.lovelaceModule.cardMod
    pkgs.hs.lovelaceModule.foldEntityRow
    pkgs.hs.lovelaceModule.miniGraphCard
    pkgs.hs.lovelaceModule.simpleThermostat
  ];

  theme = pkgs.hs.theme.googleHome;

  #̉ TODO HOME-ASSISTANT automatically apply to "custom:simple-thermostat"
  simpleThermostatStyle = ''
    .header__title {
      color: var(--ha-card-header-color) !important;
    }

    .mode-item.active, .mode-item.active:hover {
      background: var(--mdc-theme-primary) !important;
    }
  '';
in {
  systemd.tmpfiles.rules = [ "d /run/hass 0700 nginx nginx" ]
    ++ map (lovelaceModule: "L+ /run/hass/${lovelaceModule.pname}.js - - - - ${lovelaceModule}/${lovelaceModule.pname}.js") lovelaceModules;

  services = {
    nginx.virtualHosts."home-assistant" = { locations."/local/" = { alias = "/run/hass/"; }; };

    home-assistant = {
      config = {
        frontend.themes = "!include ${theme}/${theme.pname}.yaml";

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

        resources = map (lovelaceModule: {
          url = "/local/${lovelaceModule.pname}.js?v=${lovelaceModule.version}";
          type = "module";
        }) lovelaceModules;

        views = [{
          title = "Default";
          cards = [
            {
              type = "custom:simple-thermostat";
              entity = "climate.netatmo_home";

              header = {
                name = "Netatmo";
                icon = false;
              };

              control = {
                hvac.auto.icon = "mdi:autorenew";

                preset = {
                  "Frost Guard".icon = "mdi:snowflake";
                  Schedule.icon = "mdi:calendar-sync";
                  away.icon = "mdi:home-export-outline";
                  boost.icon = "mdi:thermometer-plus";
                };
              };

              style = simpleThermostatStyle;
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
              type = "custom:mini-graph-card";
              name = "Speedtest";

              hours_to_show = 24 * 7;
              points_per_hour = 2;
              update_interval = 60;
              line_width = 3;

              show = {
                icon = false;
                fill = false;
              };

              entities = [
                {
                  name = "Download";
                  entity = "sensor.speedtest_download";
                }
                {
                  name = "Upload";
                  entity = "sensor.speedtest_upload";
                }
              ];
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
