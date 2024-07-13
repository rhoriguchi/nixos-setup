{
  services.home-assistant.config = {
    automation = [
      {
        alias = "Turn Bedroom closet lights on after 10 minutes";
        trigger = [{
          platform = "state";
          entity_id = "light.bedroom_closet_lights";
          to = "off";
          for.minutes = 10;
        }];
        action = [{
          service = "light.turn_on";
          target.entity_id = "light.bedroom_closet_lights";
        }];
      }

      {
        alias = "Turn Lego bonsai lights on when sunset";
        trigger = [{
          platform = "sun";
          event = "sunset";
        }];
        action = [{
          service = "light.turn_on";
          target.entity_id = "light.lego_bonsai";
        }];
      }
      {
        alias = "Turn Lego bonsai lights off when sunrise";
        trigger = [{
          platform = "sun";
          event = "sunrise";
        }];
        action = [{
          service = "light.turn_off";
          target.entity_id = "light.lego_bonsai";
        }];
      }

      {
        alias = "Turn Reduit closet lights on when sliding door is open";
        trigger = [{
          platform = "state";
          entity_id = "binary_sensor.reduit_parasoll_contact";
          to = "on";
        }];
        action = [{
          service = "light.turn_on";
          target.entity_id = "light.reduit_closet_lights";
        }];
      }
      {
        alias = "Turn Reduit closet lights off when sliding door is closed";
        trigger = [{
          platform = "state";
          entity_id = "binary_sensor.reduit_parasoll_contact";
          to = "off";
        }];
        action = [{
          service = "light.turn_off";
          target.entity_id = "light.reduit_closet_lights";
        }];
      }
    ];

    light = [{
      platform = "template";
      lights = {
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
