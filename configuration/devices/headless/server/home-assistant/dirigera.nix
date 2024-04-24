{
  services.home-assistant.config = {
    automation = [
      {
        alias = "Turn Bedroom closet lights on after 1 second";
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
        bedroom_lamp = {
          friendly_name = "Bedroom lamp";
          value_template = "{{ states('switch.bedroom_lamp') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.bedroom_lamp";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.bedroom_lamp";
          };
        };
        entrance_ceiling_lamp = {
          friendly_name = "Entrance ceiling lamp";
          value_template = "{{ states('switch.entrance_ceiling_lamp') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.entrance_ceiling_lamp";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.entrance_ceiling_lamp";
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
        living_room_lamp = {
          friendly_name = "Living room lamp";
          value_template = "{{ states('switch.living_room_lamp') }}";
          turn_on = {
            service = "switch.turn_on";
            target.entity_id = "switch.living_room_lamp";
          };
          turn_off = {
            service = "switch.turn_off";
            target.entity_id = "switch.living_room_lamp";
          };
        };
      };
    }];
  };
}
