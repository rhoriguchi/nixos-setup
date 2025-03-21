{ config, lib, pkgs, secrets, ... }: {
  services = {
    nginx = {
      enable = true;

      virtualHosts."monitoring.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.monitoring.webPort}";
          basicAuth = secrets.nginx.basicAuth."monitoring.00a.ch";

          extraConfig = ''
            satisfy any;

            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "monitoring.00a.ch" ];
    };

    monitoring = lib.mkForce {
      enable = true;

      type = "parent";
      claimToken = secrets.monitoring.claimToken;
      apiKey = secrets.monitoring.apiKey;
      discordWebhookUrl = secrets.monitoring.discordWebhookUrl;
    };

    netdata.configDir = {
      "go.d/windows.conf" = (pkgs.formats.yaml { }).generate "windows.conf" {
        jobs = [{
          name = "XXLPitu-Nnoitra";
          vnode = "XXLPitu-Nnoitra";
          url = "http://XXLPitu-Nnoitra.local:9182/metrics";
          autodetection_retry = 60;
        }];
      };

      "vnodes/vnodes.conf" = (pkgs.formats.yaml { }).generate "vnodes.conf" [{
        hostname = "XXLPitu-Nnoitra";
        guid = "29e86a04-22b3-4d4b-9a4c-b4d35764ee84";
      }];
    };
  };
}
