{ pkgs, lib, ... }:
let
  configFile = (pkgs.formats.ini { }).generate "glances.conf" {
    connections.disable = false;
    diskio.hide = lib.concatStringsSep "," [ "^dm-\\d+$" "^loop\\d+$" "^mmcblk\\d+p\\d+$" "^nvme0n\\d+p\\d+$" "^sd[a-z]+\\d+$" ];
    fs = {
      allow = "cifs,zfs";
      hide = builtins.storeDir;
    };
    global.check_update = false;
    irq.disable = true;
    network.hide = lib.concatStringsSep "," [ "lo" "^virbr\\d+$" "^vnet\\d+$" "^veth\\d+$" "^podman\\d+$" "^wg-\\w+$" ];
  };
in {
  environment = {
    systemPackages = [ pkgs.glances ];

    shellAliases.glances =
      "${pkgs.glances}/bin/glances ${lib.concatStringsSep " " [ "--byte" "--config ${configFile}" "--disable-irix" "--time 1" ]}";
  };
}
