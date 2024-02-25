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
            service = "frontend.set_theme";
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

                entities = [{
                  name = "Outdoor";
                  entity = "sensor.openweather_current_temperature";
                }];
              }
              {
                type = "entities";
                title = "Bedroom";

                entities = [{
                  name = "Temperature";
                  entity = "sensor.netatmo_current_temperature_bedroom";
                }];
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
                # TODO HOME-ASSISTANT toggle is broken
                type = "entities";
                title = "Lights";

                show_header_toggle = true;

                entities = [
                  {
                    type = "custom:fold-entity-row";
                    head = "light.mystrom_light_switches";
                    entities = [ { entity = "light.mystrom_light_switch_1"; } { entity = "light.mystrom_light_switch_2"; } ];
                  }
                  {
                    type = "custom:fold-entity-row";
                    head = "light.shelly_lights";
                    entities = [ { entity = "light.shelly_light_1"; } { entity = "light.shelly_light_2"; } ];
                  }
                  {
                    type = "custom:fold-entity-row";
                    head = "light.yeelight_lights";
                    entities = [ { entity = "light.yeelight_light_1"; } { entity = "light.yeelight_light_2"; } ];
                  }
                  { type = "divider"; }
                  {
                    type = "custom:fold-entity-row";
                    head = "light.airgradient_one";
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

                collapse = [
                  {
                    name = "Netatmo valves {range}%";
                    entities =
                      [ "sensor.valve_blue_battery_percent" "sensor.valve_green_battery_percent" "sensor.valve_yellow_battery_percent" ];
                  }
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
                ];
              }
            ];
          }
          {
            title = "Server";
            icon = "mdi:server";

            cards = addStyleToCards [
              {
                type = "entities";
                title = "Info";
                entities = [
                  {
                    name = "Last boot";
                    entity = "sensor.booted";
                  }
                  {
                    name = "Uptime";
                    entity = "sensor.uptime";
                  }
                  {
                    name = "OS";
                    entity = "sensor.os";
                  }
                  {
                    name = "Version";
                    entity = "sensor.version";
                  }
                  {
                    name = "Installed Kernel";
                    entity = "sensor.installed_kernel";
                  }
                  {
                    name = "Active Kernel";
                    entity = "sensor.active_kernel";
                  }
                ];
              }
              {
                type = "entities";
                title = "CPU";
                entities = [{
                  name = "Load";
                  entity = "sensor.cpu_load";
                }];
              }
              {
                type = "entities";
                title = "RAM";
                entities = [{
                  name = "Used";
                  entity = "sensor.ram_used";
                }];
              }
              {
                type = "entities";
                title = "Storage";
                entities = let
                  a = string: lib.toLower string;
                  b = string: (lib.replaceStrings [ "/" ] [ "_" ]) (a string);
                  c = string: (lib.replaceStrings [ "__" ] [ "_" ]) (b string);
                  d = string: (lib.removeSuffix "_") (c string);

                  format = string: d string;
                in lib.mapAttrsToList (path: _: {
                  name = path;
                  entity = format "sensor.disk_use_${path}";
                }) config.fileSystems;
              }
              {
                type = "entities";
                title = "Interfaces";
                entities = lib.mapAttrsToList (key: _: {
                  type = "custom:fold-entity-row";
                  head = {
                    name = key;
                    entity = "sensor.ipv4_address_${key}";
                  };

                  open = true;
                  # TODO use this when resolved https://github.com/thomasloven/lovelace-fold-entity-row/issues/232
                  # open = "{{ not is_state('sensor.ipv4_address_${key}', 'unknown') }}";

                  entities = [
                    {
                      name = "Down";
                      entity = "sensor.network_throughput_in_${key}";
                    }
                    {
                      name = "Up";
                      entity = "sensor.network_throughput_out_${key}";
                    }
                  ];
                }) config.networking.interfaces;
              }
              {
                type = "entities";
                title = "AdGuard Home";
                entities = [
                  {
                    name = "Protection";
                    entity = "switch.adguard_protection";
                  }
                  {
                    name = "Average DNS query time";
                    entity = "sensor.filtered_adguard_average_dns_query_time";
                    icon = "mdi:eye";
                  }
                  {
                    name = "DNS queries per hour";
                    entity = "sensor.filtered_adguard_dns_queries_per_hour";
                    icon = "mdi:eye";
                  }
                  {
                    name = "Blocked DNS queries per hour";
                    entity = "sensor.filtered_adguard_blocked_dns_queries_per_hour";
                    icon = "mdi:eye";
                  }
                ];
              }
              {
                type = "entities";
                title = "Deluge";

                entities = [{
                  type = "custom:fold-entity-row";
                  head = {
                    name = "State";
                    entity = "sensor.deluge_status_formatted";
                  };

                  open = true;
                  # TODO use this when resolved https://github.com/thomasloven/lovelace-fold-entity-row/issues/232
                  # open = "{{ not is_state('sensor.deluge_status', 'Idle') }}";

                  entities = [
                    {
                      name = "Download";
                      entity = "sensor.deluge_down_speed_formatted";
                    }
                    {
                      name = "Upload";
                      entity = "sensor.deluge_up_speed_formatted";
                    }
                  ];
                }];
              }
              {
                type = "entities";
                title = "Plex";

                entities = [
                  {
                    name = "Streams";
                    entity = "sensor.plex_stream_count";
                  }
                  {
                    type = "custom:fold-entity-row";
                    head = {
                      name = "Bandwidth";
                      entity = "sensor.plex_total_bandwidth";
                    };

                    open = true;

                    entities = [
                      {
                        name = "WAN";
                        entity = "sensor.plex_wan_bandwidth";
                      }
                      {
                        name = "LAN";
                        entity = "sensor.plex_lan_bandwidth";
                      }
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
