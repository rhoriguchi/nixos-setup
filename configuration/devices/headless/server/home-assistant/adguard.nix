{ pkgs, lib, ... }:
let
  username = (import ../../../../secrets.nix).services.home-assistant.config.adguard.username;
  password = (import ../../../../secrets.nix).services.home-assistant.config.adguard.password;

  # TODO get hostname from "configuration/devices/headless/raspberry-pi-4-b-8gb/adguard/default.nix"
  hostname = "XXLPitu-AdGuard.local";

  pythonWithPackages = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.adguardhome ]);

  script = methodCall:
    pkgs.writeText "adguard_${methodCall}.py" ''
      import asyncio

      from adguardhome import AdGuardHome


      async def get_status():
          async with AdGuardHome("${hostname}", username="${username}", password="${password}", port=80) as adguard:
              print(await adguard.protection_enabled())


      async def set_status(status):
          async with AdGuardHome("${hostname}", username="${username}", password="${password}", port=80) as adguard:
              if status:
                  await adguard.enable_protection()
              else:
                  await adguard.disable_protection()


      if __name__ == "__main__":
          loop = asyncio.get_event_loop()
          loop.run_until_complete(${methodCall})
    '';
in {
  services.home-assistant.config = {
    shell_command = {
      disable_adguard_protection = "${pythonWithPackages}/bin/python ${script "set_status(False)"}";
      enable_adguard_protection = "${pythonWithPackages}/bin/python ${script "set_status(True)"}";
    };

    sensor = [{
      platform = "command_line";
      name = "AdGuard protection";
      scan_interval = 5;
      command = "${pythonWithPackages}/bin/python ${script "get_status()"}";
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
