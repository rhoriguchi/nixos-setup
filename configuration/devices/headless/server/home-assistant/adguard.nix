{ pkgs, secrets, ... }:
let
  username = secrets.adguard.username;
  password = secrets.adguard.password;

  hostname = "XXLPitu-AdGuard.local";

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

  pythonWithPackages = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.adguardhome ]);
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
