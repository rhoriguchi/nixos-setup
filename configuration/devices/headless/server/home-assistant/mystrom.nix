{ pkgs, lib, ... }:
let
  email = (import ../../../../secrets.nix).services.home-assistant.config.mystrom.email;
  password = (import ../../../../secrets.nix).services.home-assistant.config.mystrom.password;

  mystromApiUrl = "https://mystrom.ch/api";

  # TODO HOME-ASSISTANT get all values and then create separate sensor with just voltage
  createVoltageShellScript = id:
    pkgs.writeShellScript "mystrom_get_voltage_${id}" ''
      export PATH=${lib.makeBinPath [ pkgs.curl pkgs.jq ]}

      TOKEN=$(curl --request POST "${mystromApiUrl}/auth" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "email=${email}" \
        --data-urlencode "password=${password}" 2>/dev/null \
        | jq -r ".authToken")

      VOLTAGE=$(curl "${mystromApiUrl}/devices" \
        --header "Auth-Token: $TOKEN" 2>/dev/null \
        | jq -r ".devices" \
        | jq -r -c "map(select(any(.id; contains(\"${id}\")))|.voltage)[]")

      echo $VOLTAGE
    '';
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

    sensor = [
      # TODO HOME-ASSISTANT find out how to calculate percentage
      {
        platform = "command_line";
        name = "myStrom button blue voltage";
        unit_of_measurement = "V";
        scan_interval = 60 * 60;
        command = "${pkgs.bash}/bin/bash ${createVoltageShellScript "F4CFA2E9DACB"}";
      }
      {
        platform = "command_line";
        name = "myStrom button orange voltage";
        unit_of_measurement = "V";
        scan_interval = 60 * 60;
        command = "${pkgs.bash}/bin/bash ${createVoltageShellScript "F4CFA2E9DAD9"}";
      }
    ];

    automation = [
      {
        alias = "Turn on entrance lights";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_blue";
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.entrance";
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
