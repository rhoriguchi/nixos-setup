{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.glances;

  configFile = (pkgs.formats.toml { }).generate "glances.conf" {
    diskio.hide = "loop*, zram*, mmcblk*";
    fs.hide = "mmcblk.*";
    global.check_update = true;
    network.hide = "veth*, lo";
  };
in {
  options.glances = {
    enable = mkEnableOption "Glances";
    port = mkOption {
      default = 61208;
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    users.users.glances.isSystemUser = true;

    systemd.services.glances = {
      description = "Glances";
      serviceConfig = {
        ExecStart =
          "${pkgs.glances}/bin/glances --config ${configFile} --webserver --time 1 --byte --port ${
            toString cfg.port
          }";
        Restart = "on-abort";
        User = "glances";
      };
      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
