{ lib, ... }:
let
  switches = {
    bedroom = {
      id = "bedroom_dimmer_switch_button";
      buttons = {
        power = "2819c8f1-5dc5-4fcb-bafe-c7bc4fa595c5";
        up = "ae296fae-ecc0-47cd-b54e-ec913f5666c9";
        down = "1499685c-45e0-4ff6-9acc-5ebda9266a34";
        hue = "40aa54e0-2678-4738-ab02-a68a3f56f01f";
      };
    };
    entrance = {
      id = "entrance_dimmer_switch_button";
      buttons = {
        power = "165c3f81-a23a-42ac-89ea-2daa0efa6572";
        up = "d6c12a95-7924-49a8-b782-4792bf04e459";
        down = "e25e17ec-6e2d-4a30-bbbd-65dab1462b65";
        hue = "f2d227d2-299b-4a71-9e61-822411905d9c";
      };
    };
    kitchen = {
      id = "kitchen_dimmer_switch_button";
      buttons = {
        power = "57c96761-dbaf-41ac-8295-957d7efcfc72";
        up = "0f58fa50-d758-42ce-8e49-82567c617494";
        down = "94b42bfb-3681-4b86-bb5d-e4da98976557";
        hue = "561bd416-cb41-4f5c-a20f-c79e9e674fde";
      };
    };
  };

  createSwitchAutomations = let steps = 6;
  in data: [
    {
      alias = "Toggle ${data.name} lights";
      triggers = [{
        trigger = "event";
        event_type = "hue_event";
        event_data = {
          id = data.switch.id;
          unique_id = data.switch.buttons.power;
          type = "initial_press";
        };
      }];
      actions = [{
        action = "light.toggle";
        target.entity_id = data.targetId;
      }];
    }
    {
      alias = "Brighten ${data.name} lights";
      triggers = [
        {
          trigger = "event";
          event_type = "hue_event";
          event_data = {
            id = data.switch.id;
            unique_id = data.switch.buttons.up;
            type = "initial_press";
          };
        }
        {
          trigger = "event";
          event_type = "hue_event";
          event_data = {
            id = data.switch.id;
            unique_id = data.switch.buttons.up;
            type = "repeat";
          };
        }
      ];
      conditions = [{
        condition = "numeric_state";
        entity_id = data.targetId;
        attribute = "brightness";
        above = 0;
      }];
      actions = [{
        action = "light.turn_on";
        target.entity_id = data.targetId;
        data.brightness = ''
          {% set step = (255 / ${toString steps}) | int %}
          {% set current_brightness = state_attr('${data.targetId}', 'brightness') | int(0) %}
          {% set new_brightness = current_brightness + step %}


          {% if current_brightness == 0 %}
            0
          {% elif new_brightness >= (255 - step) %}
            255
          {% else %}
            {{ new_brightness }}
          {% endif %}
        '';
      }];
    }
    {
      alias = "Dim ${data.name} lights";
      triggers = [
        {
          trigger = "event";
          event_type = "hue_event";
          event_data = {
            id = data.switch.id;
            unique_id = data.switch.buttons.down;
            type = "initial_press";
          };
        }
        {
          trigger = "event";
          event_type = "hue_event";
          event_data = {
            id = data.switch.id;
            unique_id = data.switch.buttons.down;
            type = "repeat";
          };
        }
      ];
      conditions = [{
        condition = "numeric_state";
        entity_id = data.targetId;
        attribute = "brightness";
        above = 0;
      }];
      actions = [{
        action = "light.turn_on";
        target.entity_id = data.targetId;
        data.brightness = ''
          {% set step = (255 / ${toString steps}) | int %}
          {% set current_brightness = state_attr('${data.targetId}', 'brightness') | int(0) %}
          {% set new_brightness = current_brightness - step %}

          {% if current_brightness == 0 %}
            0
          {% elif new_brightness <= step %}
            {{ current_brightness }}
          {% else %}
            {{ new_brightness }}
          {% endif %}
        '';
      }];
    }
  ];
in {
  services.home-assistant.config.automation = [
    {
      alias = "Reset living room Signe Gradient kitchen when turned on";
      triggers = [{
        trigger = "state";
        entity_id = "light.living_room_signe_gradient_kitchen";
        from = "off";
        to = "on";
      }];
      actions = [{
        action = "light.turn_on";
        target.entity_id = "light.living_room_signe_gradient_kitchen";
        data.color_temp_kelvin = 3600;
      }];
    }
    {
      alias = "Reset living room Signe Gradient window when turned on";
      triggers = [{
        trigger = "state";
        entity_id = "light.living_room_signe_gradient_window";
        from = "off";
        to = "on";
      }];
      actions = [{
        action = "light.turn_on";
        target.entity_id = "light.living_room_signe_gradient_window";
        data.color_temp_kelvin = 3600;
      }];
    }
    {
      alias = "Toggle hallway light";
      triggers = [
        {
          trigger = "event";
          event_type = "hue_event";
          event_data = {
            id = switches.bedroom.id;
            unique_id = switches.bedroom.buttons.hue;
            type = "initial_press";
          };
        }
        {
          trigger = "event";
          event_type = "hue_event";
          event_data = {
            id = switches.kitchen.id;
            unique_id = switches.kitchen.buttons.hue;
            type = "initial_press";
          };
        }
      ];
      actions = [{
        action = "light.toggle";
        target.entity_id = "light.hallway_lamp";
      }];
    }
  ] ++ lib.flatten (map (data: createSwitchAutomations data) [
    {
      name = "bedroom";
      targetId = "light.group_switch_bedroom";
      switch = switches.bedroom;
    }
    {
      name = "entrance";
      targetId = "light.group_switch_entrance";
      switch = switches.entrance;
    }
    {
      name = "kitchen and living room";
      targetId = "light.group_switch_kitchen";
      switch = switches.kitchen;
    }
  ]);
}
