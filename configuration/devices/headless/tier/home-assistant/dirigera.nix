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

    template = [
      {
        light = {
          name = "Dining room standing lamp";
          default_entity_id = "light.dining_room_standing_lamp";
          state = "{{ states('switch.dining_room_standing_lamp') }}";
          turn_on = [
            {
              target.entity_id = [ "switch.dining_room_standing_lamp" ];
              action = "switch.turn_on";
            }
          ];
          turn_off = [
            {
              target.entity_id = [ "switch.dining_room_standing_lamp" ];
              action = "switch.turn_off";
            }
          ];
        };
      }
      {
        light = {
          name = "Living room standing lamp";
          default_entity_id = "light.living_room_standing_lamp";
          state = "{{ states('switch.living_room_standing_lamp') }}";
          turn_on = [
            {
              target.entity_id = [ "switch.living_room_standing_lamp" ];
              action = "switch.turn_on";
            }
          ];
          turn_off = [
            {
              target.entity_id = [ "switch.living_room_standing_lamp" ];
              action = "switch.turn_off";
            }
          ];
        };
      }
      {
        light = {
          name = "Living room table lamp";
          default_entity_id = "light.living_room_table_lamp";
          state = "{{ states('switch.living_room_table_lamp') }}";
          turn_on = [
            {
              target.entity_id = [ "switch.living_room_table_lamp" ];
              action = "switch.turn_on";
            }
          ];
          turn_off = [
            {
              target.entity_id = [ "switch.living_room_table_lamp" ];
              action = "switch.turn_off";
            }
          ];
        };
      }
    ];
  };
}
