{
  config,
  lib,
  pkgs,
  ...
}:
let
  polygon = map (p: {
    x = builtins.elemAt p 0;
    y = builtins.elemAt p 1;
  });

  area =
    {
      id,
      name,
      points,
      entity ? null,
    }:
    {
      inherit id name;
      points = polygon points;
      showName = true;
      labelSize = 22;
      opacity = 0;
    }
    // lib.optionalAttrs (entity != null) {
      inherit entity;
      activeColor = "#ffd54f";
      activeOpacity = 0.35;
    };

  light = id: entity: x: y: {
    inherit
      id
      entity
      x
      y
      ;
    kind = "light";
  };

  climate =
    {
      id,
      temperature,
      humidity,
      x,
      y,
      extra ? [ ],
      labelPosition ? "below",
    }:
    {
      inherit
        id
        x
        y
        labelPosition
        ;
      entity = temperature;
      kind = "sensor";
      readings = [ { entity = humidity; } ] ++ extra;
    };

  dashboardFile = (pkgs.formats.yaml { }).generate "floor-plan.yaml" {
    title = "Floor Plan";

    views = [
      {
        title = "Floor Plan";
        path = "floor-plan";
        type = "panel";

        cards = [
          {
            type = "custom:easy-floorplan-card";
            width = 1300;
            height = 1162;
            overlayScale = "plan";

            floors = [
              {
                id = "home";
                name = "Home";
                image = "/local/img/plan.png";
                imageFit = "stretch";

                areas = [
                  (area {
                    id = "bedroom";
                    name = "Bedroom";
                    entity = "light.group_bedroom";
                    points = [
                      [
                        160
                        155
                      ]
                      [
                        515
                        155
                      ]
                      [
                        515
                        469
                      ]
                      [
                        160
                        469
                      ]
                    ];
                  })
                  (area {
                    id = "guest_room";
                    name = "Guest room";
                    entity = "light.group_guest_room";
                    points = [
                      [
                        525
                        155
                      ]
                      [
                        886
                        155
                      ]
                      [
                        886
                        469
                      ]
                      [
                        525
                        469
                      ]
                    ];
                  })
                  (area {
                    id = "office";
                    name = "Office";
                    entity = "light.group_office";
                    points = [
                      [
                        897
                        155
                      ]
                      [
                        1253
                        155
                      ]
                      [
                        1253
                        534
                      ]
                      [
                        1047
                        534
                      ]
                      [
                        1047
                        469
                      ]
                      [
                        897
                        469
                      ]
                    ];
                  })
                  (area {
                    id = "dining_room";
                    name = "Dining room";
                    entity = "light.group_dining_room";
                    points = [
                      [
                        130
                        479
                      ]
                      [
                        507
                        479
                      ]
                      [
                        507
                        799
                      ]
                      [
                        130
                        799
                      ]
                    ];
                  })
                  (area {
                    id = "kitchen";
                    name = "Kitchen";
                    entity = "light.group_kitchen";
                    points = [
                      [
                        507
                        479
                      ]
                      [
                        911
                        479
                      ]
                      [
                        911
                        799
                      ]
                      [
                        507
                        799
                      ]
                    ];
                  })
                  (area {
                    id = "living_room";
                    name = "Living room";
                    entity = "light.group_living_room";
                    points = [
                      [
                        317
                        816
                      ]
                      [
                        651
                        816
                      ]
                      [
                        651
                        1115
                      ]
                      [
                        317
                        1115
                      ]
                    ];
                  })
                  (area {
                    id = "loggia";
                    name = "Loggia";
                    points = [
                      [
                        130
                        799
                      ]
                      [
                        317
                        799
                      ]
                      [
                        317
                        1115
                      ]
                      [
                        130
                        1115
                      ]
                    ];
                  })
                  (area {
                    id = "reduit";
                    name = "Reduit";
                    points = [
                      [
                        1047
                        545
                      ]
                      [
                        1253
                        545
                      ]
                      [
                        1253
                        669
                      ]
                      [
                        1047
                        669
                      ]
                    ];
                  })
                  (area {
                    id = "bathroom_1";
                    name = "Bathroom 1";
                    points = [
                      [
                        1047
                        705
                      ]
                      [
                        1240
                        705
                      ]
                      [
                        1240
                        901
                      ]
                      [
                        1047
                        901
                      ]
                    ];
                  })
                  (area {
                    id = "bathroom_2";
                    name = "Bathroom 2";
                    points = [
                      [
                        675
                        963
                      ]
                      [
                        878
                        963
                      ]
                      [
                        878
                        1125
                      ]
                      [
                        675
                        1125
                      ]
                    ];
                  })
                ];

                items = [
                  (light "bedroom_nightstand_lamp_left" "light.bedroom_nightstand_lamp_left" 185 425)
                  (light "bedroom_nightstand_lamp_right" "light.bedroom_nightstand_lamp_right" 185 185)
                  (light "bedroom_standing_lamp" "light.bedroom_standing_lamp" 430 185)
                  (climate {
                    id = "bedroom_climate";
                    temperature = "sensor.bedroom_h_t_gen3_temperature";
                    humidity = "sensor.bedroom_h_t_gen3_humidity";
                    labelPosition = "right";
                    x = 337;
                    y = 141;
                  })

                  (light "guest_room_closet_lights" "light.guest_room_closet_lights" 550 445)
                  (climate {
                    id = "guest_room_climate";
                    temperature = "sensor.guest_room_h_t_gen3_temperature";
                    humidity = "sensor.guest_room_h_t_gen3_humidity";
                    labelPosition = "right";
                    x = 705;
                    y = 141;
                  })

                  (light "office_signe_gradient_wall" "light.office_signe_gradient_wall" 1221 452)
                  (light "office_signe_gradient_door" "light.office_signe_gradient_door" 1039 452)
                  (climate {
                    id = "office_climate";
                    temperature = "sensor.office_vindstyrka_temperature_sensor";
                    humidity = "sensor.office_vindstyrka_humidity_sensor";
                    labelPosition = "right";
                    x = 1095;
                    y = 508;
                  })

                  (light "living_room_standing_lamp" "light.living_room_standing_lamp" 345 1088)
                  (light "living_room_table_lamp" "light.living_room_table_lamp" 625 1088)
                  (climate {
                    id = "living_room_climate";
                    temperature = "sensor.living_room_h_t_gen3_temperature";
                    humidity = "sensor.living_room_h_t_gen3_humidity";
                    labelPosition = "left";
                    x = 565;
                    y = 1088;
                  })

                  (light "dining_room_standing_lamp" "light.dining_room_standing_lamp" 158 634)
                  (light "kitchen_cabinet_lights" "light.kitchen_cabinet_lights" 595 495)
                  (climate {
                    id = "kitchen_climate";
                    temperature = "sensor.airgradient_one_temperature";
                    humidity = "sensor.airgradient_one_humidity";
                    extra = [ { entity = "sensor.airgradient_one_carbon_dioxide"; } ];
                    labelPosition = "right";
                    x = 655;
                    y = 495;
                  })

                  (climate {
                    id = "reduit_climate";
                    temperature = "sensor.reduit_h_t_gen3_temperature";
                    humidity = "sensor.reduit_h_t_gen3_humidity";
                    labelPosition = "right";
                    x = 1095;
                    y = 560;
                  })
                  {
                    id = "reduit_leak";
                    entity = "binary_sensor.reduit_badring_leak_sensor";
                    kind = "binary_sensor";
                    x = 1222;
                    y = 635;
                  }
                  (climate {
                    id = "network_closet_climate";
                    temperature = "sensor.network_closet_h_t_gen3_temperature";
                    humidity = "sensor.network_closet_h_t_gen3_humidity";
                    labelPosition = "right";
                    x = 1095;
                    y = 684;
                  })
                ];
              }
            ];
          }
        ];
      }
    ];
  };
in
{
  services = {
    nginx.virtualHosts."home-assistant.00a.ch".locations."= /local/img/plan.png".alias = "${
      ./plan.png
    }";

    home-assistant = {
      customLovelaceModules = [ pkgs.home-assistant-custom-lovelace-modules.easy-floorplan ];

      config.lovelace.dashboards.floor-plan = {
        mode = "yaml";
        filename = "floor-plan.yaml";
        title = "Floor Plan";
        icon = "mdi:floor-plan";
        show_in_sidebar = true;
      };
    };
  };

  systemd.services.home-assistant.preStart = lib.mkAfter ''
    ln -sf ${dashboardFile} "${config.services.home-assistant.configDir}/floor-plan.yaml"
  '';
}
