{ pkgs, ... }: {
  services.home-assistant.config = {
    sensor = [{
      platform = "command_line";
      name = "Speedtest";
      scan_interval = 60 * 30;
      command_timeout = 60 * 5;
      command = "${pkgs.speedtest-cli}/bin/speedtest --json --secure";
      json_attributes = [ "download" "upload" ];
      value_template = "{{ value_json.ping }}";
      unit_of_measurement = "ms";
    }];

    template = [{
      sensor = [
        {
          name = "Speedtest download";
          icon = "mdi:download";
          state = "{{ (state_attr('sensor.speedtest', 'download') / (1024 * 1024)) | round(2) }}";
          unit_of_measurement = "Mb/s";
        }
        {
          name = "Speedtest upload";
          icon = "mdi:upload";
          state = "{{ (state_attr('sensor.speedtest', 'upload') / (1024 * 1024)) | round(2) }}";
          unit_of_measurement = "Mb/s";
        }
      ];
    }];
  };
}
