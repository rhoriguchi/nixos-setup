{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.infomaniak;
in
{
  options.services.infomaniak = {
    enable = lib.mkEnableOption "Infomaniak DDNS updater";
    username = lib.mkOption { type = lib.types.str; };
    password = lib.mkOption { type = lib.types.str; };
    hostnames = lib.mkOption { type = lib.types.listOf lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.username != "";
        message = "Username cannot be empty";
      }
      {
        assertion = cfg.password != "";
        message = "Password cannot be empty";
      }
      {
        assertion = cfg.hostnames != [ ];
        message = "Hostnames list cannot be empty";
      }
    ];

    services.ddclient = {
      enable = true;

      interval = "5min";

      server = "infomaniak.com";
      ssl = true;

      inherit (cfg) username;
      passwordFile = "${pkgs.writeText "ddclient-password" cfg.password}";
      domains = cfg.hostnames;
    };
  };
}
