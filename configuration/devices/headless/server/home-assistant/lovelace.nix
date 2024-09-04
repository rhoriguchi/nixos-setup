{ pkgs, lib, config, ... }:
let
  lovelaceModules = [
    pkgs.hs.lovelaceModule.battery-state-card
    pkgs.hs.lovelaceModule.card-mod
    pkgs.hs.lovelaceModule.fold-entity-row
    pkgs.hs.lovelaceModule.mini-graph-card
  ];

  theme = pkgs.hs.theme.google-home;

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
    map (card:
      (card // lib.optionalAttrs (lib.hasAttr card.type cardStyles) { card_mod.style = cardStyles.${card.type}; }
        // lib.optionalAttrs (lib.hasAttr "cards" card) { cards = addStyleToCards card.cards; })) cards;
in {
  systemd.tmpfiles.rules = [
    "d /run/hass 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
    "d /run/hass/js 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
  ] ++ map (lovelaceModule: "L+ /run/hass/js/${lovelaceModule.pname}.js - - - - ${lovelaceModule}/${lovelaceModule.pname}.js")
    lovelaceModules;

  services = {
    nginx.virtualHosts."home-assistant.00a.ch".locations."/local/".alias = "/run/hass/";

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
            action = "frontend.set_theme";
            data.name = "Google - Light";
          }];
        }];

        lovelace.resources = map (lovelaceModule: {
          url = "/local/js/${lovelaceModule.pname}.js?v=${lovelaceModule.version}";
          type = "module";
        }) lovelaceModules;
      };

      lovelaceConfig = {
        title = "Home";

        views = [{
          title = "Home";
          icon = "mdi:home";

          cards = addStyleToCards [
            {
              type = "custom:mini-graph-card";
              name = "Outdoor temperature";

              hours_to_show = 24 * 7;
              points_per_hour = 2;
              line_width = 3;
              hour24 = true;

              show = {
                icon = false;
                fill = false;
              };

              entities = [{
                name = "Outdoor";
                entity = "sensor.openweather_current_temperature";
              }];
            }
            {
              type = "entities";
              title = "Bedroom";

              entities = [
                {
                  name = "Temperature";
                  entity = "sensor.plus_h_t_temperature";
                }
                {
                  name = "Humidity";
                  entity = "sensor.plus_h_t_humidity";
                }
              ];
            }
            {
              type = "entities";
              title = "Entrance";

              entities = [
                {
                  name = "Temperature";
                  entity = "sensor.netatmo_current_temperature_entrance";
                }
                {
                  name = "Humidity";
                  entity = "sensor.stadler_form_karl_humidity";
                }
              ];
            }
            {
              type = "entities";
              title = "Living room";

              entities = [
                {
                  name = "Temperature";
                  entity = "sensor.airgradient_one_temperature";
                }
                {
                  name = "Humidity";
                  entity = "sensor.airgradient_one_humidity";
                }
                {
                  name = "CO2";
                  entity = "sensor.airgradient_one_co2";
                }
                {
                  name = "VOC Index";
                  entity = "sensor.airgradient_one_voc_index";
                }
                {
                  name = "NOx Index";
                  entity = "sensor.airgradient_one_nox_index";
                }
                {
                  name = "PM 1.0 μm";
                  entity = "sensor.airgradient_one_pm_1_0";
                }
                {
                  name = "PM 2.5 μm";
                  entity = "sensor.airgradient_one_pm_10_0";
                }
                {
                  name = "PM 10.0 μm";
                  entity = "sensor.airgradient_one_pm_2_5";
                }
              ];
            }
            {
              type = "entities";
              title = "Stadler Form Karl";

              entities = [
                {
                  name = "Power";
                  entity = "switch.stadler_form_karl_power";
                  icon = "mdi:power";
                }
                {
                  type = "conditional";
                  conditions = [{
                    entity = "switch.stadler_form_karl_power";
                    state = "on";
                  }];
                  row = {
                    name = "Auto mode";
                    entity = "switch.stadler_form_karl_auto_mode";
                    icon = "mdi:fan-auto";
                  };
                }
                {
                  type = "conditional";
                  conditions = [
                    {
                      entity = "switch.stadler_form_karl_power";
                      state = "on";
                    }
                    {
                      entity = "switch.stadler_form_karl_auto_mode";
                      state = "on";
                    }
                  ];
                  row = {
                    name = "Hygrostat";
                    entity = "select.stadler_form_karl_hygrostat";
                    icon = "mdi:water-percent";
                  };
                }
                {
                  type = "conditional";
                  conditions = [
                    {
                      entity = "switch.stadler_form_karl_power";
                      state = "on";
                    }
                    {
                      entity = "switch.stadler_form_karl_auto_mode";
                      state = "off";
                    }
                  ];
                  row = {
                    name = "Fan speed";
                    entity = "select.stadler_form_karl_fan_speed";
                    icon = "mdi:fan";
                  };
                }
                {
                  name = "Low water";
                  entity = "binary_sensor.stadler_form_karl_low_water";
                  icon = "mdi:water";
                }
                {
                  name = "Filter life";
                  entity = "sensor.stadler_form_karl_filter_life";
                  icon = "mdi:filter";
                }
              ];
            }
            {
              type = "entities";
              title = "Lights";

              show_header_toggle = true;

              entities = [
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "Bedroom";
                    entity = "light.group_bedroom";
                  };

                  open = true;

                  entities = [
                    {
                      name = "Closet lights";
                      entity = "light.bedroom_closet_lights";
                    }
                    {
                      name = "Nightstand lamp left";
                      entity = "light.bedroom_nightstand_lamp_left";
                    }
                    {
                      name = "Nightstand lamp right";
                      entity = "light.bedroom_nightstand_lamp_right";
                    }
                    {
                      name = "Standing lamp";
                      entity = "light.bedroom_standing_lamp";
                    }
                  ];
                }
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "Entrance";
                    entity = "light.group_entrance";
                  };

                  open = true;

                  entities = [
                    {
                      name = "Sideboard lamp";
                      entity = "light.entrance_sideboard_lamp";
                    }
                    {
                      type = "custom:fold-entity-row";
                      head = "light.remove_yeelight_lights";
                      entities = [ "light.remove_yeelight_light_1" "light.remove_yeelight_light_2" ];
                    }
                  ];
                }
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "Hallway";
                    entity = "light.group_hallway";
                  };

                  open = true;

                  entities = [{
                    name = "Lamp";
                    entity = "light.hallway_lamp";
                  }];
                }
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "Kitchen";
                    entity = "light.group_kitchen";
                  };

                  open = true;

                  entities = [{
                    name = "Lamp";
                    entity = "light.kitchen_standing_lamp";
                  }];
                }
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "Living room";
                    entity = "light.group_living_room";
                  };

                  open = true;

                  entities = [
                    "light.living_room_signe_gradient_kitchen"
                    "light.living_room_signe_gradient_window"
                    {
                      name = "Standing lamp";
                      entity = "light.living_room_standing_lamp";
                    }
                    {
                      name = "Table lamp";
                      entity = "light.living_room_table_lamp";
                    }
                  ];
                }
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "Reduit";
                    entity = "light.group_reduit";
                  };

                  open = true;

                  entities = [{
                    name = "Lamp";
                    entity = "light.reduit_closet_lights";
                  }];
                }
                { type = "divider"; }
                {
                  type = "custom:fold-entity-row";
                  head = {
                    name = "Lego";
                    entity = "light.group_lego";
                  };

                  open = true;

                  entities = [{
                    name = "Bonsai";
                    entity = "light.lego_bonsai";
                  }];
                }
                { type = "divider"; }
                {
                  type = "custom:fold-entity-row";
                  head = "light.airgradient_one";

                  open = true;

                  entities = [
                    {
                      name = "Display";
                      entity = "light.airgradient_one_display";
                    }
                    {
                      name = "Led";
                      entity = "light.airgradient_one_led_strip";
                    }
                  ];
                }
              ];
            }
            {
              type = "vertical-stack";

              cards = [
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
                  type = "picture";
                  image = "/local/img/wifi-guest-qr.png";
                }
              ];
            }
            {
              type = "custom:battery-state-card";
              title = "Battery";

              bulk_rename = [ { from = " Battery Percent"; } { from = " battery"; } { from = "myStrom button "; } { from = "Valve "; } ];
              sort.by = "name";

              entities = [
                {
                  name = "Reduit Parasoll";
                  entity = "sensor.reduit_parasoll_battery";
                }
                {
                  name = "Shelly H&T Gen3";
                  entity = "sensor.plus_h_t_battery";
                }
              ];

              collapse = [
                {
                  name = "myStrom buttons {range}%";
                  entities = [
                    "sensor.mystrom_button_blue_battery"
                    "sensor.mystrom_button_gray_battery"
                    "sensor.mystrom_button_orange_battery"
                    "sensor.mystrom_button_purple_battery"
                    "sensor.mystrom_button_white_battery"
                  ];
                }
                {
                  name = "Netatmo valves {range}%";
                  entities = [
                    "sensor.valve_blue_battery_percent"
                    "sensor.valve_green_battery_percent"
                    "sensor.valve_orange_battery_percent"
                    "sensor.valve_yellow_battery_percent"
                  ];
                }
              ];
            }
          ];
        }];
      };
    };
  };
}
