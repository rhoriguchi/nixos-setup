{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.tv_time_export;

  configFile = (pkgs.formats.yaml { }).generate "config.yaml" {
    username = cfg.username;
    password = cfg.password;
    save_path = cfg.exportPath;
  };
in {
  options.tv_time_export = {
    enable = mkEnableOption "tv_time_export";
    exportPath = mkOption { type = types.str; };
    username = mkOption { type = types.str; };
    password = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.exportPath != "";
        message = "Export path cannot be empty.";
      }
      {
        assertion = cfg.username != "";
        message = "Username cannot be empty.";
      }
      {
        assertion = cfg.password != "";
        message = "Password cannot be empty.";
      }
    ];

    users.users.tv_time_export = {
      isSystemUser = true;
      extraGroups = optional config.rslsync.enable "rslsync";
    };

    systemd.services.tv_time_export = {
      after = [ "network.target" ];
      description = "tv_time_export";
      serviceConfig = {
        ExecStart = "${pkgs.tv_time_export}/bin/tv_time_export ${configFile}";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.exportPath}";
        Restart = "on-abort";
        UMask = "0007";
        User = "mal_export";
      };
      startAt = "06:00";
    };
  };
}
