{ pkgs, secrets, ... }:
let
  apiUrl = "https://mystrom.ch/api";

  getVoltageScript = id:
    pkgs.writers.writePython3 "mystrom_get_voltage_${id}.py" { libraries = [ pkgs.python3Packages.requests ]; } ''
      import json

      import requests

      response = requests.post('${apiUrl}/auth', params={
          'email': '${secrets.mystrom.email}',
          'password': '${secrets.mystrom.password}'
      })

      response = requests.get(
        url='${apiUrl}/devices',
        headers={'Auth-Token': json.loads(response.content)['authToken']}
      )

      match = next(filter(
          lambda device: device['id'] == '${id}',
          json.loads(response.content)['devices']
      ))

      print(match['voltage'])
    '';

  createButtonBatterySensors = map (button: {
    sensor = {
      name = button.name;
      scan_interval = 60 * 60;
      command = getVoltageScript button.id;
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
        alias = "Placeholder myStrom orange";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_orange";
          local_only = true;
        }];
        action = [ ];
      }
      {
        alias = "Placeholder myStrom purple";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_purple";
          local_only = true;
        }];
        action = [ ];
      }
      {
        alias = "Placeholder myStrom blue";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_blue";
          local_only = true;
        }];
        action = [ ];
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
