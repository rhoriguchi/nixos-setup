{ pkgs, lib, config, ... }:
let
  createResources = types: map (type: { inherit type; }) types;

  createResourcesWithArg = arg: types: map (type: { inherit type arg; }) types;
  createResourcesWithArgs = args: types: lib.flatten (map (arg: createResourcesWithArg arg types) args);
in {
  services.home-assistant.config.sensor = [
    {
      platform = "systemmonitor";
      resources = (createResources [ "last_boot" "memory_use_percent" "processor_use" ])
        ++ (createResourcesWithArgs (lib.attrNames config.fileSystems) [ "disk_use_percent" ])
        ++ (createResourcesWithArgs (lib.attrNames config.networking.interfaces) [
          "ipv4_address"
          "throughput_network_in"
          "throughput_network_out"
        ]);
    }
    {
      platform = "command_line";
      name = "Uptime";
      scan_interval = 60;
      command =
        "${pkgs.coreutils}/bin/uptime | ${pkgs.gawk}/bin/awk -F '( |,|:)+' '{d=h=m=0; if ($7==\"min\") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,\"days\",h+0,\"hours\",m+0,\"minutes\"}'";
    }
  ];
}