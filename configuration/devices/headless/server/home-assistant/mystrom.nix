{ pkgs, secrets, ... }:
let
  apiUrl = "https://mystrom.ch/api";

  getXScript = id: key:
    pkgs.writeText "mystrom_get_${key}_${id}.py" ''
      import json

      import requests

      response = requests.post('${apiUrl}/auth', params={
          'email': '${secrets.mystrom.email}',
          'password': '${secrets.mystrom.password}'
      })

      response = requests.get('${apiUrl}/devices', headers={'Auth-Token': json.loads(response.content)['authToken']})

      match = next(filter(
          lambda device: device['id'] == '${id}',
          json.loads(response.content)['devices']
      ))

      print(match['${key}'])
    '';

  getVoltageScript = id: getXScript id "voltage";
  getPowerScript = id: getXScript id "power";

  pythonWithPackages = pkgs.python3.withPackages (ps: [ ps.requests ]);

  createButtonBatterySensors = map (button: {
    sensor = {
      name = button.name;
      scan_interval = 60 * 60;
      command = "${pythonWithPackages}/bin/python ${getVoltageScript button.id}";
      value_template = let
        maxVoltage = "4300";
        minVoltage = "3700";
      in "{{ (((value | float) * 1000 - ${minVoltage}) * 100 / (${maxVoltage} - ${minVoltage})) | round }}";
      unit_of_measurement = "%";
      device_class = "battery";
      state_class = "measurement";
    };
  });
in {
  services.home-assistant.config = {
    light = [{
      platform = "template";
      lights.living_room = {
        friendly_name = "Living room";
        value_template = "{{ states('switch.mystrom_living_room_light_switch') }}";
        turn_on = {
          service = "switch.turn_on";
          target.entity_id = "switch.mystrom_living_room_light_switch";
        };
        turn_off = {
          service = "switch.turn_off";
          target.entity_id = "switch.mystrom_living_room_light_switch";
        };
      };
    }];

    command_line = createButtonBatterySensors [
      {
        name = "myStrom button blue battery";
        id = "F4CFA2E9DACB";
      }
      {
        name = "myStrom button gray battery";
        id = "F4CFA2E9DA8E";
      }
      {
        name = "myStrom button orange battery";
        id = "F4CFA2E9DAD9";
      }
      {
        name = "myStrom button purple battery";
        id = "F4CFA2E9D761";
      }
      {
        name = "myStrom button white battery";
        id = "CC50E3F8CB7A";
      }
    ] ++ [{
      sensor = {
        name = "myStrom Desk Monitor power consumption";
        scan_interval = 60;
        command = "${pythonWithPackages}/bin/python ${getPowerScript "083AF2A56094"}";
        value_template = "{{ value | round }}";
        unit_of_measurement = "W";
        state_class = "measurement";
      };
    }];

    automation = [
      {
        alias = "Turn on bedroom light";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_gray";
          local_only = true;
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.bedroom";
          data = {
            brightness = 255;
            color_temp = 333;
            transition = 0.1;
          };
        }];
      }
      {
        alias = "Turn on entrance lights";
        trigger = [
          {
            platform = "webhook";
            webhook_id = "mystrom_button_blue";
            local_only = true;
          }
          {
            platform = "webhook";
            webhook_id = "mystrom_button_purple";
            local_only = true;
          }
        ];
        action = [{
          service = "light.toggle";
          entity_id = "light.entrance";
          data = {
            brightness = 255;
            rgb_color = [ 255 205 166 ];
            transition = 0.1;
          };
        }];
      }
      {
        alias = "Turn on kitchen light";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_white";
          local_only = true;
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.kitchen";
          data = {
            brightness = 255;
            color_temp = 210;
            transition = 0.1;
          };
        }];
      }
      {
        alias = "Turn on living room light";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_orange";
          local_only = true;
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.living_room";
        }];
      }
    ];
  };
}
