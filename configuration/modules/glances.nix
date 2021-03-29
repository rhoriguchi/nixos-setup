{ lib, config, pkgs, ... }:
let cfg = config.services.glances;
in {
  options.services.glances = {
    enable = lib.mkEnableOption "Glances";
    port = lib.mkOption {
      default = 61208;
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.glances.isSystemUser = true;

    systemd.services.glances = {
      description = "Glances";
      serviceConfig = {
        ExecStart = "${pkgs.glances}/bin/glances --webserver --port ${toString cfg.port}";
        Restart = "on-abort";
        User = "glances";
      };
      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
