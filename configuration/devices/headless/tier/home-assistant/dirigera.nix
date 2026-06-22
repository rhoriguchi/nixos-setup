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

      {
        alias = "Reset Kitchen cabinet lights when turned on";
        triggers = [
          {
            trigger = "state";
            entity_id = "light.kitchen_cabinet_lights";
            from = "off";
            to = "on";
          }
        ];
        actions = [
          {
            action = "light.turn_on";
            target.entity_id = "light.kitchen_cabinet_lights";
            data.brightness = 255;
          }
        ];
      }
      {
        alias = "Turn Kitchen cabinet lights on when sunset";
        triggers = [
          {
            trigger = "sun";
            event = "sunset";
          }
        ];
        actions = [
          {
            action = "light.turn_on";
            target.entity_id = "light.kitchen_cabinet_lights";
          }
        ];
      }
      {
        alias = "Turn Kitchen cabinet lights off when sunrise";
        triggers = [
          {
            trigger = "sun";
            event = "sunrise";
          }
        ];
        actions = [
          {
            action = "light.turn_off";
            target.entity_id = "light.kitchen_cabinet_lights";
          }
        ];
      }
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
