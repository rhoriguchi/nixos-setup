{ pkgs, lib, config, ... }:
let
  getDiskUsageScript = path:
    pkgs.writeShellScript "disk_usage_${(lib.replaceStrings [ "/" " " ] [ "_" "_" ]) path}.sh" ''
      total=$(${pkgs.coreutils}/bin/df ${path} | ${pkgs.gawk}/bin/awk 'NR==2 {print $2}')
      used=$(${pkgs.coreutils}/bin/df ${path} | ${pkgs.gawk}/bin/awk 'NR==2 {print $3}')

      echo "scale=10; 100 * $used / $total" | ${pkgs.bc}/bin/bc
    '';

  getThroughputScript = interface: key:
    pkgs.writeShellScript "network_throughput_${key}_${interface}.sh" ''
      start=$(${pkgs.iproute2}/bin/ifstat -j ${interface} | ${pkgs.jq}/bin/jq '.kernel | to_entries[] | .value.${key}')

      sleep 1

      end=$(${pkgs.iproute2}/bin/ifstat -j ${interface} | ${pkgs.jq}/bin/jq '.kernel | to_entries[] | .value.${key}')

      echo $((end - start))
    '';
in {
  services.home-assistant.config = {
    template = [{
      sensor = [
        {
          name = "Uptime";
          state = "{{ states('sensor.last_boot') | as_datetime | relative_time }}";
        }
        {
          name = "Booted";
          state = "{{ states('sensor.last_boot') | as_timestamp | timestamp_custom('%d.%m.%Y %H:%M:%S') }}";
        }
        {
          name = "Installed Kernel";
          state = config.boot.kernelPackages.kernel.version;
        }
      ];
    }];

    command_line = [
      {
        sensor = {
          name = "OS";
          scan_interval = 24 * 60 * 60;
          command = "${pkgs.lsb-release}/bin/lsb_release --id --short";
          value_template = "{{ value | replace('\"', '') }}";
        };
      }
      {
        sensor = {
          name = "Version";
          scan_interval = 24 * 60 * 60;
          command = "${pkgs.gnugrep}/bin/grep 'BUILD_ID=' /etc/os-release | ${pkgs.coreutils}/bin/cut -d'=' -f2";
          value_template = "{{ value | replace('\"', '') }}";
        };
      }
      {
        sensor = {
          name = "Active Kernel";
          scan_interval = 24 * 60 * 60;
          command = "${pkgs.coreutils}/bin/uname -r";
        };
      }
      {
        sensor = {
          name = "Last boot";
          scan_interval = 24 * 60 * 60;
          command = "${pkgs.coreutils}/bin/date -d \"$(${pkgs.coreutils}/bin/who -b | ${pkgs.gawk}/bin/awk '{print $3, $4}')\" +'%s'";
          value_template = "{{ value | int | timestamp_local }}";
          device_class = "timestamp";
        };
      }
      {
        sensor = {
          name = "RAM used";
          icon = "mdi:memory";
          scan_interval = 30;
          command = "${pkgs.procps}/bin/free | ${pkgs.gawk}/bin/awk '/Mem/ {printf(\"%.2f\"), $3/$2*100}'";
          value_template = "{{ value | float }}";
          unit_of_measurement = "%";
          state_class = "measurement";
        };
      }
      {
        sensor = {
          name = "CPU load";
          icon = "mdi:cpu-64-bit";
          scan_interval = 30;
          command = "${pkgs.sysstat}/bin/sar -u 1 1 | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.gawk}/bin/awk '{print 100 - $NF}'";
          value_template = "{{ value | float }}";
          unit_of_measurement = "%";
          state_class = "measurement";
        };
      }
    ] ++ (lib.mapAttrsToList (path: _: {
      sensor = {
        name = "Disk use ${path}";
        icon = "mdi:harddisk";
        scan_interval = 5 * 60;
        command = "${pkgs.bashInteractive}/bin/sh ${getDiskUsageScript path}";
        value_template = "{{ value | float | round(3) }}";
        unit_of_measurement = "%";
        state_class = "measurement";
      };
    }) config.fileSystems) ++ (lib.flatten (lib.mapAttrsToList (interface: _: [
      {
        sensor = {
          name = "IPv4 address ${interface}";
          icon = "mdi:ip-network";
          scan_interval = 5 * 60;
          command =
            "${pkgs.iproute2}/bin/ip addr show ${interface} | ${pkgs.gawk}/bin/awk '/inet / {print $2}' | ${pkgs.coreutils}/bin/cut -f1 -d'/'";
        };
      }
      {
        sensor = {
          name = "Network throughput in ${interface}";
          scan_interval = 30;
          command = "${pkgs.bashInteractive}/bin/sh ${getThroughputScript interface "rx_bytes"}";
          value_template = "{{ ((value | float) / 1024 / 1024) | round(3) }}";
          unit_of_measurement = "MB/s";
          device_class = "data_rate";
          state_class = "measurement";
        };
      }
      {
        sensor = {
          name = "Network throughput out ${interface}";
          scan_interval = 30;
          command = "${pkgs.bashInteractive}/bin/sh ${getThroughputScript interface "tx_bytes"}";
          value_template = "{{ ((value | float) / 1024 / 1024) | round(3) }}";
          unit_of_measurement = "MB/s";
          device_class = "data_rate";
          state_class = "measurement";
        };
      }
    ]) config.networking.interfaces));
  };
}
