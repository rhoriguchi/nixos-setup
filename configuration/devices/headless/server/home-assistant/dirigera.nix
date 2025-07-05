{
  services.home-assistant.config = {
    automation = [
      {
        alias = "Reset hallway lamp when turned on";
        triggers = [{
          trigger = "state";
          entity_id = "light.hallway_lamp";
          from = "off";
          to = "on";
        }];
        actions = [{
          action = "light.turn_on";
          target.entity_id = "light.hallway_lamp";
          data.rgb_color = [ 255 179 109 ];
        }];
      }
      {
        alias = "Reset living room table lamp when turned on";
        triggers = [{
          trigger = "state";
          entity_id = "light.living_room_table_lamp";
          from = "off";
          to = "on";
        }];
        actions = [{
          action = "light.turn_on";
          target.entity_id = "light.living_room_table_lamp";
          data.rgb_color = [ 255 179 109 ];
        }];
      }

      {
        alias = "Turn bedroom closet lights on after 10 minutes";
        triggers = [{
          trigger = "state";
          entity_id = "light.bedroom_closet_lights";
          to = "off";
          for.minutes = 10;
        }];
        actions = [{
          action = "light.turn_on";
          target.entity_id = "light.bedroom_closet_lights";
        }];
      }

      {
        alias = "Dim bedroom closet lights when sunset";
        triggers = [{
          trigger = "sun";
          event = "sunset";
        }];
        actions = [{
          action = "light.turn_on";
          target.entity_id = "light.bedroom_closet_lights";
          data.brightness = 1;
        }];
      }
      {
        alias = "Brighten bedroom closet lights when sunrise";
        triggers = [{
          trigger = "sun";
          event = "sunrise";
        }];
        actions = [{
          action = "light.turn_off";
          target.entity_id = "light.bedroom_closet_lights";
          data.brightness = 255;
        }];
      }

      {
        alias = "Turn Lego lights on when sunset";
        triggers = [{
          trigger = "sun";
          event = "sunset";
        }];
        actions = [{
          action = "light.turn_on";
          target.entity_id = "light.group_lego";
        }];
      }
      {
        alias = "Turn Lego lights off when sunrise";
        triggers = [{
          trigger = "sun";
          event = "sunrise";
        }];
        actions = [{
          action = "light.turn_off";
          target.entity_id = "light.group_lego";
        }];
      }

      {
        alias = "Turn reduit closet lights on when sliding door is open";
        triggers = [{
          trigger = "state";
          entity_id = "binary_sensor.reduit_parasoll_contact";
          to = "on";
        }];
        actions = [{
          action = "light.turn_on";
          target.entity_id = "light.reduit_closet_lights";
        }];
      }
      {
        alias = "Turn reduit closet lights off when sliding door is closed";
        triggers = [{
          trigger = "state";
          entity_id = "binary_sensor.reduit_parasoll_contact";
          to = "off";
        }];
        actions = [{
          action = "light.turn_off";
          target.entity_id = "light.reduit_closet_lights";
        }];
      }
      {
        alias = "Turn reduit closet lights off after 10 minutes";
        triggers = [{
          trigger = "state";
          entity_id = "light.reduit_closet_lights";
          to = "on";
          for.minutes = 10;
        }];
        actions = [{
          action = "light.turn_off";
          target.entity_id = "light.reduit_closet_lights";
        }];
      }
    ];

    light = [{
      platform = "template";
      lights = {
        entrance_lamp = {
          friendly_name = "Entrance lamp";
          value_template = "{{ states('switch.entrance_lamp') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.entrance_lamp";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.entrance_lamp";
          };
        };
        entrance_sideboard_lamp = {
          friendly_name = "Entrance sideboard lamp";
          value_template = "{{ states('switch.entrance_sideboard_lamp') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.entrance_sideboard_lamp";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.entrance_sideboard_lamp";
          };
        };
        lego_bonsai = {
          friendly_name = "Lego bonsai";
          value_template = "{{ states('switch.lego_bonsai') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.lego_bonsai";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.lego_bonsai";
          };
        };
        lego_chrysanthemum = {
          friendly_name = "Lego Chrysanthemum";
          value_template = "{{ states('switch.lego_chrysanthemum') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.lego_chrysanthemum";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.lego_chrysanthemum";
          };
        };
        lego_tales_of_the_space_age = {
          friendly_name = "Lego Tales of the Space Age";
          value_template = "{{ states('switch.lego_tales_of_space_age') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.lego_tales_of_space_age";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.lego_tales_of_space_age";
          };
        };
        living_room_standing_lamp = {
          friendly_name = "Living room standing lamp";
          value_template = "{{ states('switch.living_room_standing_lamp') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.living_room_standing_lamp";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.living_room_standing_lamp";
          };
        };
        kitchen_standing_lamp = {
          friendly_name = "Kitchen standing lamp";
          value_template = "{{ states('switch.kitchen_standing_lamp') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.kitchen_standing_lamp";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.kitchen_standing_lamp";
          };
        };
      };
    }];
  };
}
