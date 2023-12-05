{ config, pkgs, lib, ... }:
let
  cfg = config.services.monitoring;

  serverAddress = "monitoring.00a.ch";
  streamPort = 19996;

  isParent = cfg.type == "parent";
in {
  options.services.monitoring = {
    enable = lib.mkEnableOption "Monitoring with Netdata";
    type = lib.mkOption { type = lib.types.nullOr (lib.types.enum [ "parent" "child" ]); };
    basicAuth = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
    apiKey = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = isParent -> config.services.infomaniak.enable;
        message = "When type is server infomaniak service must be enabled";
      }
      {
        assertion = isParent -> config.services.nginx.enable;
        message = "When type is server nginx service must be enabled";
      }
      {
        assertion = isParent -> cfg.basicAuth != { };
        message = "When type is server basicAuth must be set";
      }
    ];

    services = {
      infomaniak.hostnames = lib.mkIf isParent [ serverAddress ];

      netdata = {
        enable = true;

        package = pkgs.netdata.override { withCloudUi = isParent; };

        # TODO monitor
        # HDD temperature
        # Minecraft
        # NGINX https://learn.netdata.cloud/docs/data-collection/web-servers-and-web-proxies/nginx
        # Nvidia GPU
        # S.M.A.R.T.

        # TODO fix ssl issue
        # https://community.netdata.cloud/t/streaming-not-working-when-activating-ssl/764/7
        # https://github.com/netdata/netdata/issues/6457#issuecomment-511430698

        # TODO install on windows (Plugin: go.d.plugin Module: windows)

        config = {
          parent.web = {
            "bind to" = lib.concatStringsSep " " [
              "0.0.0.0=dashboard|registry|badges|management|netdata.conf^SSL=force"
              "0.0.0.0:${toString streamPort}=streaming^SSL=force"
            ];
            "ssl certificate" = "/run/monitoring/cert.pem";
            "ssl ssl key" = "/run/monitoring/key.pem";

            "enable gzip compression" = "no";
          };

          child = {
            global."memory mode" = "ram";

            web.node = "none";
          };
        }.${cfg.type};

        configDir."stream.conf" = (pkgs.formats.ini { }).generate "stream.conf" {
          parent.${cfg.apiKey} = {
            enabled = "yes";

            "default memory mode" = "dbengine";
          };

          child.stream = {
            enabled = "yes";

            "api key" = cfg.apiKey;
            destination = "${serverAddress}:${toString streamPort}";

            "ssl skip certificate verification" = "yes";
          };
        }.${cfg.type};
      };
    };

    systemd.tmpfiles.rules = let certDir = "/var/lib/acme/monitoring.00a.ch";
    in lib.mkIf isParent [
      "d /run/monitoring 0700 ${config.services.netdata.user} ${config.services.netdata.group}"
      "L+ /run/monitoring/cert.pem - - - - ${certDir}/cert.pem"
      "L+ /run/monitoring/key.pem - - - - ${certDir}/key.pem"
    ];

    networking.firewall = {
      allowedTCPPorts = lib.mkIf isParent [ 19999 streamPort ];
      allowedUDPPorts = lib.mkIf isParent [ 19999 streamPort ];
    };

    # TODO cause `error: The option `services.monitoring.type' is used but not defined.`
    # networking.firewall = lib.optionalAttrs isParent {
    #   allowedTCPPorts = [ streamPort ];
    #   allowedUDPPorts = [ streamPort ];
    # };
  };
}

