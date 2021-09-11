{ pkgs, lib, ... }:
let
  email = (import ../../../../secrets.nix).services.home-assistant.config.mystrom.email;
  password = (import ../../../../secrets.nix).services.home-assistant.config.mystrom.password;

  apiUrl = "https://mystrom.ch/api";

  createVoltageShellScript = id:
    pkgs.writeShellScript "mystrom_get_voltage_${id}" ''
      export PATH=${lib.makeBinPath [ pkgs.curl pkgs.jq ]}

      TOKEN=$(curl --request POST "${apiUrl}/auth" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "email=${email}" \
        --data-urlencode "password=${password}" 2>/dev/null \
        | jq -r ".authToken")

      VOLTAGE=$(curl "${apiUrl}/devices" \
        --header "Auth-Token: $TOKEN" 2>/dev/null \
        | jq -r ".devices" \
        | jq -r -c "map(select(any(.id; contains(\"${id}\")))|.voltage)[]")

      echo $VOLTAGE
    '';

  createButtonBatterySensors = buttons:
    map (button: {
      platform = "command_line";
      name = button.name;
      scan_interval = 6 * 60 * 60;
      command = "${createVoltageShellScript button.id}";
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

    light = [
      {
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
      }
      {
        platform = "group";
        name = "Kitchen + Living room";
        entities = [ "light.kitchen" "light.living_room" ];
      }
    ];

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
            # TODO HOME-ASSISTANT tweak color
            brightness = 255;
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
          data.brightness = 255;
        }];
      }
      {
        alias = "Turn on kitchen and living room lights";
        trigger = [{
          platform = "webhook";
          webhook_id = "mystrom_button_orange";
        }];
        action = [{
          service = "light.toggle";
          entity_id = "light.kitchen_living_room";
          data = {
            brightness = 255;
            transition = 0.1;
          };
        }];
      }
    ];
  };
}
