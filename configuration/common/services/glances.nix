{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.glances;

  configFile = (pkgs.formats.ini { }).generate "glances.conf" {
    connections.disable = false;
    diskio.hide = "loop\\d+,^mmcblk\\d+$,^sd[a-z]+$";
    fs.hide = "/nix/store";
    global.check_update = false;
    network.hide = "lo";
  };
in {
  options.services.glances = {
    enable = mkEnableOption "Glances";
    port = mkOption {
      default = 61208;
      type = types.port;
    };
  };

  config = mkIf cfg.enable {
    users.users.glances.isSystemUser = true;

    systemd.services.glances = {
      description = "Glances";
      serviceConfig = {
        ExecStart =
          "${pkgs.glances}/bin/glances --config ${configFile} --time 1 --byte --webserver --port ${
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
