{ lib, config, pkgs, ... }:
let cfg = config.services.audio-converter;
in {
  options.services.audio-converter = {
    enable = lib.mkEnableOption "audio-converter";
    user = lib.mkOption {
      type = lib.types.str;
      default = "audio-converter";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "audio-converter";
    };
    path = lib.mkOption { type = lib.types.str; };
    from = lib.mkOption { type = lib.types.str; };
    to = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.path != "";
        message = "Path cannot be empty";
      }
      {
        assertion = cfg.from != "";
        message = "From cannot be empty";
      }
      {
        assertion = cfg.to != "";
        message = "To cannot be empty";
      }
    ];

    users = {
      users = lib.optionalAttrs (cfg.user == "audio-converter") {
        audio-converter = {
          isSystemUser = true;
          group = cfg.group;
        };
      };

      groups = lib.optionalAttrs (cfg.group == "audio-converter") { audio-converter = { }; };
    };

    systemd.services.audio-converter = {
      after = [ "network.target" ];
      description = "audio-converter";
      serviceConfig = {
        ExecStart = "${pkgs.audio-converter}/bin/audio-converter ${cfg.path} ${cfg.from} ${cfg.to}";
        Restart = "on-abort";
        User = cfg.user;
        Group = cfg.group;
      };
      startAt = "15:00";
    };
  };
}
