{
  services.home-assistant.config = {
    automation = [
      {
        alias = "Reset hallway lamp when turned on";
        trigger = [{
          platform = "state";
          entity_id = "light.hallway_lamp";
          from = "off";
          to = "on";
        }];
        action = [{
          action = "light.turn_on";
          target.entity_id = "light.hallway_lamp";
          data.rgb_color = [ 255 179 109 ];
        }];
      }
      {
        alias = "Reset living room table lamp when turned on";
        trigger = [{
          platform = "state";
          entity_id = "light.living_room_table_lamp";
          from = "off";
          to = "on";
        }];
        action = [{
          action = "light.turn_on";
          target.entity_id = "light.living_room_table_lamp";
          data.rgb_color = [ 255 179 109 ];
        }];
      }

      {
        alias = "Turn bedroom closet lights on after 10 minutes";
        trigger = [{
          platform = "state";
          entity_id = "light.bedroom_closet_lights";
          to = "off";
          for.minutes = 10;
        }];
        action = [{
          action = "light.turn_on";
          target.entity_id = "light.bedroom_closet_lights";
        }];
      }

      {
        alias = "Turn Lego lights on when sunset";
        trigger = [{
          platform = "sun";
          event = "sunset";
        }];
        action = [{
          action = "light.turn_on";
          target.entity_id = "light.group_lego";
        }];
      }
      {
        alias = "Turn Lego lights off when sunrise";
        trigger = [{
          platform = "sun";
          event = "sunrise";
        }];
        action = [{
          action = "light.turn_off";
          target.entity_id = "light.group_lego";
        }];
      }

      {
        alias = "Turn reduit closet lights on when sliding door is open";
        trigger = [{
          platform = "state";
          entity_id = "binary_sensor.reduit_parasoll_contact";
          to = "on";
        }];
        action = [{
          action = "light.turn_on";
          target.entity_id = "light.reduit_closet_lights";
        }];
      }
      {
        alias = "Turn reduit closet lights off when sliding door is closed";
        trigger = [{
          platform = "state";
          entity_id = "binary_sensor.reduit_parasoll_contact";
          to = "off";
        }];
        action = [{
          action = "light.turn_off";
          target.entity_id = "light.reduit_closet_lights";
        }];
      }
      {
        alias = "Turn reduit closet lights off after 10 minutes";
        trigger = [{
          platform = "state";
          entity_id = "light.reduit_closet_lights";
          to = "on";
          for.minutes = 10;
        }];
        action = [{
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
