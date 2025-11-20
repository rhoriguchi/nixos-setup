{
  config,
  lib,
  pkgs,
  ...
}:
let
  # TODO use https://nixos.wiki/wiki/Home_Assistant#Add_custom_lovelace_modules
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
        opacity: 1 !important;
      }
    '';
  };

  addStyleToCards =
    cards:
    map (
      card:
      (
        card
        // lib.optionalAttrs (lib.hasAttr card.type cardStyles) {
          card_mod.style = cardStyles.${card.type};
        }
        // lib.optionalAttrs (lib.hasAttr "cards" card) { cards = addStyleToCards card.cards; }
      )
    ) cards;
in
{
  systemd.tmpfiles.rules = [
    "d /run/nginx-hass 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
    "d /run/nginx-hass/js 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
  ]
  ++ map (
    lovelaceModule:
    "L+ /run/nginx-hass/js/${lovelaceModule.pname}.js - - - - ${lovelaceModule}/${lovelaceModule.pname}.js"
  ) lovelaceModules;

  services = {
    nginx.virtualHosts."home-assistant.00a.ch".locations."/local/".alias = "/run/nginx-hass/";

    home-assistant = {
      config = {
        frontend.themes = "!include ${theme}/${theme.pname}.yaml";

        automation = [
          {
            alias = "Set theme at startup";
            initial_state = true;
            trigger = {
              trigger = "homeassistant";
              event = "start";
            };
            actions = [
              {
                action = "frontend.set_theme";
                data.name = "Google - Light";
              }
            ];
          }
        ];

        lovelace.resources = map (lovelaceModule: {
          url = "/local/js/${lovelaceModule.pname}.js?v=${lovelaceModule.version}";
          type = "module";
        }) lovelaceModules;
      };

      lovelaceConfig = {
        title = "Home";

        views = [
          {
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

                entities = [
                  {
                    name = "Outdoor";
                    entity = "sensor.openweather_current_temperature";
                  }
                ];
              }
              {
                type = "entities";
                title = "Bedroom";

                entities = [
                  {
                    name = "Temperature";
                    entity = "sensor.bedroom_h_t_gen3_temperature";
                  }
                  {
                    name = "Humidity";
                    entity = "sensor.bedroom_h_t_gen3_humidity";
                  }
                ];
              }
              {
                type = "entities";
                title = "Dining room";

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
                    entity = "sensor.airgradient_one_carbon_dioxide";
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
                    name = "PM 1 μm";
                    entity = "sensor.airgradient_one_pm1";
                  }
                  {
                    name = "PM 2.5 μm";
                    entity = "sensor.airgradient_one_pm2_5";
                  }
                  {
                    name = "PM 10 μm";
                    entity = "sensor.airgradient_one_pm10";
                  }
                ];
              }
              {
                type = "entities";
                title = "Guest room";

                entities = [
                  {
                    name = "Temperature";
                    entity = "sensor.guest_room_h_t_gen3_temperature";
                  }
                  {
                    name = "Humidity";
                    entity = "sensor.guest_room_h_t_gen3_humidity";
                  }
                ];
              }
              {
                type = "entities";
                title = "Office";

                entities = [
                  {
                    name = "Temperature";
                    entity = "sensor.office_vindstyrka_temperature_sensor";
                  }
                  {
                    name = "Humidity";
                    entity = "sensor.office_vindstyrka_humidity_sensor";
                  }
                  {
                    name = "PM 2.5 μm";
                    entity = "sensor.office_vindstyrka_pm2_5_density";
                  }
                ];
              }
              {
                type = "entities";
                title = "Living room";

                entities = [
                  {
                    name = "Temperature";
                    entity = "sensor.living_room_h_t_gen3_temperature";
                  }
                  {
                    name = "Humidity";
                    entity = "sensor.living_room_h_t_gen3_humidity";
                  }
                ];
              }
              {
                type = "entities";
                title = "Network closet";

                entities = [
                  {
                    name = "Temperature";
                    entity = "sensor.network_closet_h_t_gen3_temperature";
                  }
                  {
                    name = "Humidity";
                    entity = "sensor.network_closet_h_t_gen3_humidity";
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
                      name = "Dining room";
                      entity = "light.group_dining_room";
                    };

                    open = true;

                    entities = [
                      {
                        name = "Standing lamp";
                        entity = "light.dining_room_standing_lamp";
                      }
                    ];
                  }
                  {
                    type = "custom:fold-entity-row";
                    head = {
                      name = "Guest room";
                      entity = "light.group_guest_room";
                    };

                    open = true;

                    entities = [
                      {
                        name = "Closet lights";
                        entity = "light.guest_room_closet_lights";
                      }
                    ];
                  }
                  {
                    type = "custom:fold-entity-row";
                    head = {
                      name = "Living room";
                      entity = "light.group_living_room";
                    };

                    open = true;

                    entities = [
                      {
                        name = "Living room standing lamp";
                        entity = "light.living_room_standing_lamp";
                      }
                      {
                        name = "Living room table lamp";
                        entity = "light.living_room_table_lamp";
                      }
                    ];
                  }
                  {
                    type = "custom:fold-entity-row";
                    head = {
                      name = "Office";
                      entity = "light.group_office";
                    };

                    open = true;

                    entities = [
                      {
                        name = "Signe Gradient wall";
                        entity = "light.office_signe_gradient_wall";
                      }
                      {
                        name = "Signe Gradient door";
                        entity = "light.office_signe_gradient_door";
                      }
                    ];
                  }
                  # TODO HS commented
                  # { type = "divider"; }
                  # {
                  #   type = "custom:fold-entity-row";
                  #   head = {
                  #     name = "Lego";
                  #     entity = "light.group_lego";
                  #   };

                  #   open = true;

                  #   entities = [
                  #     {
                  #       name = "Bonsai";
                  #       entity = "light.lego_bonsai";
                  #     }
                  #     {
                  #       name = "Chrysanthemum";
                  #       entity = "light.lego_chrysanthemum";
                  #     }
                  #     {
                  #       name = "Tales of the Space Age";
                  #       entity = "light.lego_tales_of_the_space_age";
                  #     }
                  #   ];
                  # }
                  # TODO HS commented
                  # { type = "divider"; }
                  # {
                  #   type = "custom:fold-entity-row";
                  #   head = "light.airgradient_one";

                  #   open = true;

                  #   entities = [
                  #     {
                  #       name = "Display";
                  #       entity = "light.airgradient_one_display";
                  #     }
                  #     {
                  #       name = "Led";
                  #       entity = "light.airgradient_one_led_strip";
                  #     }
                  #   ];
                  # }
                ];
              }
              {
                type = "picture";
                image = "/local/img/wifi-guest-qr.png";
              }
              {
                type = "custom:battery-state-card";
                title = "Battery";

                bulk_rename = [
                  # Phone (has to be on top else rename does not work)
                  {
                    from = "FP5 Battery level";
                    to = "Ryan Fairphone 5";
                  }
                  # TODO HS does not work
                  {
                    from = "IPhone SAMI Battery Level";
                    to = "Sarah iPhone XS";
                  }

                  # Shelly H&T Gen3
                  {
                    from = " H&T Gen3 battery";
                  }

                  # Hue Dimmer switche
                  { from = " Dimmer switch"; }
                ];
                sort.by = "name";

                # TODO HS only show if not power connected
                collapse = [
                  {
                    name = "Phone {range}%";
                    entities = [
                      "sensor.fp5_battery_level"
                      "sensor.iphone_sami_battery_level"
                    ];
                  }
                  {
                    name = "Shelly H&T Gen3 {range}%";
                    entities = [
                      "sensor.bedroom_h_t_gen3_battery"
                      "sensor.guest_room_h_t_gen3_battery"
                      "sensor.living_room_h_t_gen3_battery"
                    ];
                  }
                  {
                    name = "Hue Dimmer switche {range}%";
                    entities = [
                      "sensor.bedroom_dimmer_switch_battery"
                      "sensor.living_room_dimmer_switch_battery"
                      "sensor.office_dimmer_switch_battery"
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
