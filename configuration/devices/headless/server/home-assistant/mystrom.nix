{ pkgs, secrets, ... }:
let
  apiUrl = "https://mystrom.ch/api";

  getVoltageScript = id:
    pkgs.writeText "mystrom_get_voltage_${id}.py" ''
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

      print(match['voltage'])
    '';

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
    light = [
      {
        platform = "template";
        lights = {
          mystrom_light_switch_1 = {
            friendly_name = "myStrom Light Switch 1";
            value_template = "{{ states('switch.mystrom_light_switch_1') }}";
            turn_on = {
              service = "switch.turn_on";
              target.entity_id = "switch.mystrom_light_switch_1";
            };
            turn_off = {
              service = "switch.turn_off";
              target.entity_id = "switch.mystrom_light_switch_1";
            };
          };
          mystrom_light_switch_2 = {
            friendly_name = "myStrom Light Switch 2";
            value_template = "{{ states('switch.mystrom_light_switch_2') }}";
            turn_on = {
              service = "switch.turn_on";
              target.entity_id = "switch.mystrom_light_switch_2";
            };
            turn_off = {
              service = "switch.turn_off";
              target.entity_id = "switch.mystrom_light_switch_2";
            };
          };
        };
      }
      {
        platform = "group";
        name = "myStrom Light Switches";
        entities = [ "light.mystrom_light_switch_1" "light.mystrom_light_switch_2" ];
      }
    ];

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
    ];

    automation = [
      {
        alias = "Toggle myStrom Light Switches";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_orange";
          local_only = true;
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.mystrom_light_switches";
        }];
      }
      {
        alias = "Toggle Hue Signe gradient floor";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_purple";
          local_only = true;
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.signe_gradient_floor";
          data = {
            brightness = 255;
            color_temp = 300;
            transition = 0.1;
          };
        }];
      }
      {
        alias = "Toggle Yeelight Lights";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_blue";
          local_only = true;
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.yeelight_lights";
          data = {
            brightness = 255;
            transition = 0.1;
          };
        }];
      }
      {
        alias = "Placeholder myStrom gray";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_gray";
          local_only = true;
        }];
        action = [ ];
      }
      {
        alias = "Placeholder myStrom white";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_white";
          local_only = true;
        }];
        action = [ ];
      }
    ];
  };
}
