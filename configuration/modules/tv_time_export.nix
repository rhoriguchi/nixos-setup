{ lib, config, pkgs, ... }:
let
  cfg = config.services.tv_time_export;

  configFile = (pkgs.formats.yaml { }).generate "config.yaml" {
    username = cfg.username;
    password = cfg.password;
    save_path = cfg.exportPath;
  };
in {
  options.services.tv_time_export = {
    enable = lib.mkEnableOption "tv_time_export";
    exportPath = lib.mkOption { type = lib.types.str; };
    username = lib.mkOption { type = lib.types.str; };
    password = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.exportPath != "";
        message = "Export path cannot be empty";
      }
      {
        assertion = cfg.username != "";
        message = "Username cannot be empty";
      }
      {
        assertion = cfg.password != "";
        message = "Password cannot be empty";
      }
    ];

    users = {
      users.tv_time_export = {
        isSystemUser = true;
        group = "tv_time_export";
        extraGroups = lib.optional config.services.resilio.enable "rslsync";
      };

      groups.tv_time_export = { };
    };

    systemd.services.tv_time_export = {
      after = [ "network.target" ];
      description = "tv_time_export";
      serviceConfig = {
        ExecStartPre = ''${pkgs.coreutils}/bin/mkdir -p "${cfg.exportPath}"'';
        ExecStart = "${pkgs.tv_time_export}/bin/tv_time_export ${configFile}";
        Restart = "on-abort";
        UMask = "0002";
        User = "tv_time_export";
        Group = if config.services.resilio.enable then "rslsync" else "tv_time_export";
      };
      startAt = "06:00";
    };
  };
}
