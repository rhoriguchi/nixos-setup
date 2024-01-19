{ pkgs, lib, config, ... }:
let
  createResources = map (type: { inherit type; });

  createResourcesWithArg = arg: map (type: { inherit type arg; });
  createResourcesWithArgs = args: types: lib.flatten (map (arg: createResourcesWithArg arg types) args);
in {
  services.home-assistant.config = {
    # TODO migrate all of those to shell scripts
    sensor = [{
      platform = "systemmonitor";
      resources = (createResources [ "last_boot" "memory_use_percent" "processor_use" ])
        ++ (createResourcesWithArgs (lib.attrNames config.fileSystems) [ "disk_use_percent" ])
        ++ (createResourcesWithArgs (lib.attrNames config.networking.interfaces) [
          "ipv4_address"
          "throughput_network_in"
          "throughput_network_out"
        ]);
    }];

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
          scan_interval = 60 * 60;
          command = "${pkgs.lsb-release}/bin/lsb_release --id --short";
          value_template = "{{ value | replace('\"', '') }}";
        };
      }
      {
        sensor = {
          name = "Version";
          scan_interval = 60 * 60;
          command = "${pkgs.gnugrep}/bin/grep 'BUILD_ID=' /etc/os-release | ${pkgs.coreutils}/bin/cut -d'=' -f2";
          value_template = "{{ value | replace('\"', '') }}";
        };
      }
      {
        sensor = {
          name = "Active Kernel";
          scan_interval = 60 * 60;
          command = "${pkgs.coreutils}/bin/uname -r";
        };
      }
    ];
  };
}
