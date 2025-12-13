{
  services.home-assistant.config = {
    automation = [
      {
        alias = "Turn guest room closet lights on after 10 minutes";
        triggers = [
          {
            trigger = "state";
            entity_id = "light.guest_room_closet_lights";
            to = "off";
            for.minutes = 10;
          }
        ];
        actions = [
          {
            action = "light.turn_on";
            target.entity_id = "light.guest_room_closet_lights";
          }
        ];
      }
      # TODO HS commented
      #   {
      #     alias = "Dim bedroom closet lights when sunset";
      #     triggers = [{
      #       trigger = "sun";
      #       event = "sunset";
      #     }];
      #     actions = [{
      #       action = "light.turn_on";
      #       target.entity_id = "light.bedroom_closet_lights";
      #       data.brightness = 1;
      #     }];
      #   }
      #   {
      #     alias = "Brighten bedroom closet lights when sunrise";
      #     triggers = [{
      #       trigger = "sun";
      #       event = "sunrise";
      #     }];
      #     actions = [{
      #       action = "light.turn_off";
      #       target.entity_id = "light.bedroom_closet_lights";
      #       data.brightness = 255;
      #     }];
      #   }

      # TODO HS commented
      #   {
      #     alias = "Turn Lego lights on when sunset";
      #     triggers = [{
      #       trigger = "sun";
      #       event = "sunset";
      #     }];
      #     actions = [{
      #       action = "light.turn_on";
      #       target.entity_id = "light.group_lego";
      #     }];
      #   }
      #   {
      #     alias = "Turn Lego lights off when sunrise";
      #     triggers = [{
      #       trigger = "sun";
      #       event = "sunrise";
      #     }];
      #     actions = [{
      #       action = "light.turn_off";
      #       target.entity_id = "light.group_lego";
      #     }];
      #   }
    ];

    light = [
      {
        platform = "template";
        lights = {
          dining_room_standing_lamp = {
            friendly_name = "Living room standing lamp";
            value_template = "{{ states('switch.dining_room_standing_lamp') }}";
            turn_on = {
              service = "switch.turn_on";
              target.entity_id = "switch.dining_room_standing_lamp";
            };
            turn_off = {
              service = "switch.turn_off";
              target.entity_id = "switch.dining_room_standing_lamp";
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
          living_room_table_lamp = {
            friendly_name = "Living room table lamp";
            value_template = "{{ states('switch.living_room_table_lamp') }}";
            turn_on = {
              service = "switch.turn_on";
              target.entity_id = "switch.living_room_table_lamp";
            };
            turn_off = {
              service = "switch.turn_off";
              target.entity_id = "switch.living_room_table_lamp";
            };
          };
        };
      }
    ];
  };
}
