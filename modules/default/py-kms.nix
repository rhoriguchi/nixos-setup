{ lib, config, pkgs, ... }:
let cfg = config.services.py-kms;
in {
  options.services.py-kms = {
    enable = lib.mkEnableOption "py-kms";
    listeningPort = lib.mkOption {
      default = 1688;
      type = lib.types.port;
    };
    listeningIpAddress = lib.mkOption {
      default = "0.0.0.0";
      type = lib.types.str;
    };
    openPorts = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    storageDir = lib.mkOption {
      default = "/var/lib/py-kms";
      type = lib.types.path;
    };
    logLevel = lib.mkOption {
      default = "INFO";
      type = lib.types.enum [ "CRITICAL" "ERROR" "WARNING" "INFO" "DEBUG" "MININFO" ];
    };
    logDir = lib.mkOption {
      default = "/var/log/py-kms";
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.py-kms = {
      isSystemUser = true;
      group = "py-kms";
      createHome = true;
      home = cfg.storageDir;
    };

    users.groups.py-kms = { };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openPorts [ cfg.listeningPort ];

    system.activationScripts.py-kms = ''
      mkdir -pm 0711 "${cfg.logDir}"
      chown py-kms:py-kms "${cfg.logDir}"
    '';

    systemd.services.py-kms = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        ${pkgs.py-kms}/bin/pykms ${cfg.listeningIpAddress} ${
          toString cfg.listeningPort
        } --sqlite "${cfg.storageDir}/pykms_database.db" --loglevel ${cfg.logLevel} --logfile "${cfg.logDir}/pykms_logserver.log" --logsize 10'';

      serviceConfig = {
        Restart = "on-abort";
        User = "py-kms";
        Group = "py-kms";
      };
    };
  };
}
