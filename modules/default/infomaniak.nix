{
  config,
  lib,
  ...
}:
let
  cfg = config.services.infomaniak;
in
{
  options.services.infomaniak = {
    enable = lib.mkEnableOption "Infomaniak DDNS updater";
    username = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "nixos";
    };
    passwordFile = lib.mkOption { type = lib.types.path; };
    hostnames = lib.mkOption { type = lib.types.listOf lib.types.nonEmptyStr; };
    enableIPv6 = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.ddclient = {
      enable = true;

      interval = "5min";

      server = "infomaniak.com";
      ssl = true;

      inherit (cfg) username passwordFile;
      domains = cfg.hostnames;
    }
    // lib.optionalAttrs (!cfg.enableIPv6) {
      usev6 = "";
    };
  };
}
