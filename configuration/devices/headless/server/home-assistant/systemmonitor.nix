{ pkgs, lib, config, ... }:
let
  createResources = map (type: { inherit type; });

  createResourcesWithArg = arg: map (type: { inherit type arg; });
  createResourcesWithArgs = args: types: lib.flatten (map (arg: createResourcesWithArg arg types) args);
in {
  services.home-assistant.config = {
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
          name = "Kernel";
          scan_interval = 60 * 60;
          command = "${pkgs.coreutils}/bin/uname -r";
        };
      }
      {
        sensor = {
          name = "Uptime";
          scan_interval = 60;
          command =
            "${pkgs.coreutils}/bin/uptime | ${pkgs.gawk}/bin/awk -F '( |,|:)+' '{d=h=m=0; if ($7==\"min\") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,\"days\",h+0,\"hours\",m+0,\"minutes\"}'";
        };
      }
    ];
  };
}
