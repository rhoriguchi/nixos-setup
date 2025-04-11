{ config, lib, pkgs, ... }:
let
  cfg = config.services.steam-lancache-prefill;

  appsConfig = (pkgs.formats.json { }).generate "selectedAppsToPrefill.json" cfg.apps;
in {
  options.services.steam-lancache-prefill = {
    enable = lib.mkEnableOption "steam-lancache-prefill";
    apps = lib.mkOption { type = lib.types.listOf lib.types.number; };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/steam-lancache-prefill";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "steam-lancache-prefill";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "steam-lancache-prefill";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };

      groups.${cfg.group} = { };
    };

    systemd = {
      services.steam-lancache-prefill = {
        after = [ "network.target" ];

        script = "${pkgs.steam-lancache-prefill}/bin/SteamPrefill prefill --verbose";

        startAt = "05:00";

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = cfg.dataDir;
          Restart = "on-abort";
        };
      };

      tmpfiles.rules = [
        "d ${cfg.dataDir}/Config 0700 ${cfg.user} ${cfg.group}"
        "L+ ${cfg.dataDir}/Config/selectedAppsToPrefill.json - - - - ${appsConfig}"
      ];
    };
  };
}
