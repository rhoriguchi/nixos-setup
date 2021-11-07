{ pkgs, lib, ... }:
let
  email = (import ../../../../secrets.nix).services.home-assistant.config.mystrom.email;
  password = (import ../../../../secrets.nix).services.home-assistant.config.mystrom.password;

  apiUrl = "https://mystrom.ch/api";

  getVoltageScript = id:
    pkgs.writeText "mystrom_get_voltage_${id}.py" ''
      import json

      import requests

      response = requests.post('${apiUrl}/auth', params={
          'email': '${email}',
          'password': '${password}'
      })

      response = requests.get('${apiUrl}/devices', headers={'Auth-Token': json.loads(response.content)['authToken']})

      match = next(filter(
          lambda device: device['id'] == '${id}',
          json.loads(response.content)['devices']
      ))

      print(match['voltage'])
    '';

  pythonWithPackages = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.requests ]);

  createButtonBatterySensors = buttons:
    map (button: {
      platform = "command_line";
      name = button.name;
      scan_interval = 60 * 60 * 60;
      command = "${pythonWithPackages}/bin/python ${getVoltageScript button.id}";
      value_template = let
        maxVoltage = "4300";
        minVoltage = "3700";
      in "{{ (((value | float) * 1000 - ${minVoltage}) * 100 / (${maxVoltage} - ${minVoltage})) | round }}";
      unit_of_measurement = "%";
    }) buttons;
in {
  services.home-assistant.config = {
    switch = [{
      platform = "mystrom";
      name = "myStrom living room light switch";
      host = "myStrom-Switch-8A0F50.iot";
    }];

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

    sensor = createButtonBatterySensors [
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
    ];

    automation = [
      {
        alias = "Turn on bedroom light";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_gray";
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.bedroom";
          data = {
            brightness = 255;
            rgb_color = [ 255 177 110 ];
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
          }
          {
            platform = "webhook";
            webhook_id = "mystrom_button_purple";
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
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.kitchen";
          data = {
            brightness = 255;
            rgb_color = [ 255 177 110 ];
            rgb_color = [ 255 223 197 ];
            transition = 0.1;
          };
        }];
      }
      {
        alias = "Turn on living room light";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_orange";
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.living_room";
        }];
      }
    ];
  };
}
