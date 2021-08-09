{ pkgs, lib, ... }:
let
  authorization = (import ../../../../secrets.nix).services.home-assistant.config.adguard.authorization;

  # TODO get hostname from "configuration/devices/headless/raspberry-pi-4-b-8gb/adguard/default.nix"
  apiUrl = "http://XXLPitu-AdGuard.local/control";

  setAdguardProtection = state: ''
    ${pkgs.curl}/bin/curl --request POST "${apiUrl}/dns_config" \
      --header "Authorization: Basic ${authorization}" \
      --data '{"protection_enabled": ${state}}'
  '';
in {
  services.home-assistant.config = {
    shell_command = {
      disable_adguard_protection = setAdguardProtection "false";
      enable_adguard_protection = setAdguardProtection "true";
    };

    sensor = [{
      platform = "command_line";
      name = "AdGuard protection";
      scan_interval = 5;
      command = ''
        ${pkgs.curl}/bin/curl "${apiUrl}/status" \
          --header "Authorization: Basic ${authorization}"
      '';
      value_template = "{{ value_json.protection_enabled }}";
    }];

    switch = [{
      platform = "template";
      switches.adguard_protection = {
        friendly_name = "AdGuard protection";
        value_template = "{{ states('sensor.adguard_protection') }}";
        turn_on.service = "shell_command.enable_adguard_protection";
        turn_off.service = "shell_command.disable_adguard_protection";
        icon_template = "mdi:shield-check";
      };
    }];
  };
}
