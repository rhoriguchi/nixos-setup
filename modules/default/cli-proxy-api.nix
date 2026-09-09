{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cli-proxy-api;

  configFile = (pkgs.formats.yaml { }).generate "cli-proxy-api-config.yaml" {
    host = cfg.host;
    port = cfg.port;

    auth-dir = "/var/lib/cli-proxy-api";
    api-keys = cfg.apiKeys;
  };
in
{
  options.services.cli-proxy-api = {
    enable = lib.mkEnableOption "cli-proxy-api";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8317;
    };

    apiKeys = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.cli-proxy-api = {
        isSystemUser = true;
        group = "cli-proxy-api";
        home = "/var/lib/cli-proxy-api";
      };

      groups.cli-proxy-api = { };
    };

    environment = {
      systemPackages = [ pkgs.llm-agents.cli-proxy-api ];

      etc."cli-proxy-api/config.yaml".source = configFile;
    };

    systemd.services.cli-proxy-api = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      restartTriggers = [ configFile ];

      serviceConfig = {
        ExecStart = "${pkgs.llm-agents.cli-proxy-api}/bin/cli-proxy-api --config /etc/cli-proxy-api/config.yaml";

        User = "cli-proxy-api";
        Group = "cli-proxy-api";
        StateDirectory = "cli-proxy-api";

        Restart = "on-failure";
      };
    };
  };
}
