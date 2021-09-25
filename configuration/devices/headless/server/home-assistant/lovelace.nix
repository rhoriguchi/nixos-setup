{ pkgs, lib, ... }:
let
  lovelaceModules = [
    pkgs.hs.lovelaceModule.batteryEntity
    pkgs.hs.lovelaceModule.cardMod
    pkgs.hs.lovelaceModule.foldEntityRow
    pkgs.hs.lovelaceModule.miniGraphCard
  ];

  theme = pkgs.hs.theme.googleHome;

  cardStyles = {
    "custom:mini-graph-card" = ''
      .header span {
        color: var(--ha-card-header-color) !important;
        font-size: var(--ha-card-header-font-size, 24px) !important;
        font-weight: normal !important;
        margin-top: 10px !important;
        opacity: 1 !important;
      }
    '';
  };

  addStyleToCards = cards:
    map (card: (card // lib.optionalAttrs (lib.hasAttr card.type cardStyles) { style = cardStyles."${card.type}"; })) cards;
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
          cards = addStyleToCards [
            {
              type = "custom:mini-graph-card";
              name = "Temperature";

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
                  name = "Outdoor";
                  entity = "sensor.openweather_current_temperature";
                }
                {
                  name = "Entrance";
                  entity = "sensor.netatmo_current_temperature_entrance";
                }
                {
                  name = "Living room";
                  entity = "sensor.netatmo_current_temperature_living_room";
                }
              ];
            }
            {
              # TODO HOME-ASSISTANT toggle is broken
              type = "entities";
              title = "Lights";

              show_header_toggle = true;

              entities = [
                "light.bedroom"
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
                {
                  type = "custom:fold-entity-row";
                  head = "light.kitchen_living_room";

                  open = true;

                  entities = [
                    {
                      name = "Kitchen";
                      entity = "light.kitchen";
                    }
                    {
                      name = "Living room";
                      entity = "light.living_room";
                    }
                  ];
                }
              ];
            }
            {
              type = "entities";
              title = "AdGuard";
              entities = [{
                name = "Protection";
                entity = "switch.adguard_protection";
              }];
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
              type = "entities";
              title = "Battery";
              entities = [
                {
                  type = "custom:battery-entity";
                  name = "Netatmo entrance";
                  entity = "sensor.netatmo_entrance_battery";
                }
                {
                  type = "custom:battery-entity";
                  name = "Netatmo living room";
                  entity = "sensor.netatmo_living_room_battery";
                }
                { type = "divider"; }
                {
                  type = "custom:battery-entity";
                  name = "myStrom button blue";
                  entity = "sensor.mystrom_button_blue_battery";
                }
                {
                  type = "custom:battery-entity";
                  name = "myStrom button orange";
                  entity = "sensor.mystrom_button_orange_battery";
                }
                {
                  type = "custom:battery-entity";
                  name = "myStrom button gray";
                  entity = "sensor.mystrom_button_gray_battery";
                }
                {
                  type = "custom:battery-entity";
                  name = "myStrom button purple";
                  entity = "sensor.mystrom_button_purple_battery";
                }
                { type = "divider"; }
                {
                  type = "custom:battery-entity";
                  name = "Withings Body+";
                  entity = "sensor.withings_body_battery";
                }
              ];
            }
          ];
        }];
      };
    };
  };
}
