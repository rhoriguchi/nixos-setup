{ pkgs, lib, config, secrets, ... }:
let
  token = secrets.tautulli.token;

  ip = "127.0.0.1";

  getScript = methodCall:
    pkgs.writers.writePython3 "tautulli_${lib.replaceStrings [ "(" ")" ] [ "" "" ] methodCall}.py" {
      libraries = [ pkgs.python3Packages.pytautulli ];
    } ''
      import asyncio
      from pytautulli import PyTautulli, PyTautulliHostConfiguration


      async def get_data():
          async with PyTautulli(host_configuration=PyTautulliHostConfiguration(
                  ipaddress="${ip}",
                  api_token="${token}",
                  port=${toString config.services.tautulli.port}
          )) as client:
              value = await client.async_command("get_activity")
              return value['response']['data']


      async def get_total_bandwidth():
          return print((await get_data())['total_bandwidth'])


      async def get_lan_bandwidth():
          return print((await get_data())['lan_bandwidth'])


      async def get_wan_bandwidth():
          return print((await get_data())['wan_bandwidth'])


      async def get_stream_count():
          return print((await get_data())['stream_count'])


      if __name__ == "__main__":
          loop = asyncio.get_event_loop()
          loop.run_until_complete(${methodCall})
    '';
in {
  services.home-assistant.config.command_line = [
    {
      sensor = {
        name = "Plex total bandwidth";
        icon = "mdi:file-upload";
        scan_interval = 30;
        command = getScript "get_total_bandwidth()";
        value_template = "{{ ((value | int) / 8 / 1024) | round(3) }}";
        unit_of_measurement = "MB/s";
        state_class = "measurement";
      };
    }
    {
      sensor = {
        name = "Plex lan bandwidth";
        icon = "mdi:file-upload";
        scan_interval = 30;
        command = getScript "get_lan_bandwidth()";
        value_template = "{{ ((value | int) / 8 / 1024) | round(3) }}";
        unit_of_measurement = "MB/s";
        state_class = "measurement";
      };
    }
    {
      sensor = {
        name = "Plex wan bandwidth";
        icon = "mdi:file-upload";
        scan_interval = 30;
        command = getScript "get_wan_bandwidth()";
        value_template = "{{ ((value | int) / 8 / 1024) | round(3) }}";
        unit_of_measurement = "MB/s";
        state_class = "measurement";
      };
    }
    {
      sensor = {
        name = "Plex stream count";
        icon = "mdi:account";
        scan_interval = 30;
        command = getScript "get_stream_count()";
        value_template = "{{ value | int }}";
        state_class = "measurement";
      };
    }
  ];
}
