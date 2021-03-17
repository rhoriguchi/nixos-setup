{ lib, config, pkgs, ... }:
let
  cfg = config.services.mal_export;

  configFile = (pkgs.formats.yaml { }).generate "config.yaml" {
    username = cfg.username;
    password = cfg.password;
    save_path = cfg.exportPath;
  };
in {
  options.services.mal_export = {
    enable = lib.mkEnableOption "mal_export";
    exportPath = lib.mkOption { type = lib.types.str; };
    username = lib.mkOption { type = lib.types.str; };
    password = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
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

    users.users.mal_export = {
      isSystemUser = true;
      extraGroups = lib.optional config.services.resilio.enable "rslsync";
    };

    systemd.services.mal_export = {
      after = [ "network.target" ];
      description = "mal_export";
      serviceConfig = {
        ExecStart = "${pkgs.mal_export}/bin/mal_export ${configFile}";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.exportPath}";
        Restart = "on-abort";
        UMask = "0002";
        User = "mal_export";
      };
      startAt = "06:00";
    };
  };
}
