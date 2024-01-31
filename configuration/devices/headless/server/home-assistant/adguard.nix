{ pkgs, config, secrets, ... }:
let
  username = secrets.adguard.username;
  password = secrets.adguard.password;

  ip = "127.0.0.1";

  script = methodCall:
    pkgs.writeText "adguard_${methodCall}.py" ''
      import asyncio

      from adguardhome import AdGuardHome

      adguard = AdGuardHome("${ip}", username="${username}", password="${password}", port=${toString config.services.adguardhome.port})


      async def get_status():
          async with adguard:
              print(await adguard.protection_enabled())


      async def set_status(status):
          async with adguard:
              if status:
                  await adguard.enable_protection()
              else:
                  await adguard.disable_protection()


      async def dns_queries_per_day():
          async with adguard:
              print(await adguard.stats.dns_queries())


      async def blocked_dns_queries_per_day():
          async with adguard:
              print(await adguard.stats.blocked_filtering())


      async def avg_processing_time_per_day():
          async with adguard:
              print(await adguard.stats.avg_processing_time())


      if __name__ == "__main__":
          loop = asyncio.get_event_loop()
          loop.run_until_complete(${methodCall})
    '';

  pythonWithPackages = pkgs.python3.withPackages (ps: [ ps.adguardhome ]);
in {
  services.home-assistant.config = {
    shell_command = {
      disable_adguard_protection = "${pythonWithPackages}/bin/python ${script "set_status(False)"}";
      enable_adguard_protection = "${pythonWithPackages}/bin/python ${script "set_status(True)"}";
    };

    command_line = [
      {
        sensor = {
          name = "AdGuard protection";
          scan_interval = 5;
          command = "${pythonWithPackages}/bin/python ${script "get_status()"}";
        };
      }
      {
        sensor = {
          name = "AdGuard DNS queries per hour";
          scan_interval = 60;
          command = "${pythonWithPackages}/bin/python ${script "dns_queries_per_day()"}";
          value_template = "{{ ((value | int) / 24) | round(2) }}";
          state_class = "measurement";
        };
      }
      {
        sensor = {
          name = "AdGuard blocked DNS queries per hour";
          scan_interval = 60;
          command = "${pythonWithPackages}/bin/python ${script "blocked_dns_queries_per_day()"}";
          value_template = "{{ ((value | int) / 24) | round(2) }}";
          state_class = "measurement";
        };
      }
      {
        sensor = {
          name = "AdGuard average DNS query time";
          scan_interval = 60;
          command = "${pythonWithPackages}/bin/python ${script "avg_processing_time_per_day()"}";
          value_template = "{{ value | float }}";
          unit_of_measurement = "ms";
          state_class = "measurement";
        };
      }
    ];

    sensor = [
      {
        platform = "filter";
        name = "Filtered AdGuard DNS queries per hour";
        entity_id = "sensor.adguard_dns_queries_per_hour";
        filters = [{
          filter = "time_simple_moving_average";
          window_size = "00:05";
          precision = 2;
        }];
      }
      {
        platform = "filter";
        name = "Filtered AdGuard blocked DNS queries per hour";
        entity_id = "sensor.adguard_blocked_dns_queries_per_hour";
        filters = [{
          filter = "time_simple_moving_average";
          window_size = "00:05";
          precision = 2;
        }];
      }
      {
        platform = "filter";
        name = "Filtered AdGuard average DNS query time";
        entity_id = "sensor.adguard_average_dns_query_time";
        filters = [{
          filter = "time_simple_moving_average";
          window_size = "00:05";
          precision = 2;
        }];
      }
    ];

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

    automation = [{
      alias = "Turn AdGuard protection back on after 30 minutes";
      trigger = [{
        platform = "state";
        entity_id = "switch.adguard_protection";
        to = "off";
        for.minutes = 30;
      }];
      action = [{
        service = "switch.turn_on";
        target.entity_id = "switch.adguard_protection";
      }];
    }];
  };
}
