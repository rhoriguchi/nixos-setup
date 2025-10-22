{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  services = {
    headplane = {
      enable = true;

      settings = {
        server = {
          host = "127.0.0.1";
          port = 3001;

          cookie_secret_path = pkgs.writeText "cookieSecret" secrets.headplane.cookieSecret;
          cookie_secure = true;
        };

        headscale = {
          url = "http://127.0.0.1:${toString config.services.headscale.port}";
          public_url = config.services.headscale.settings.server_url;

          config_path = (pkgs.formats.yaml { }).generate "headscale.yml" (
            lib.recursiveUpdate config.services.headscale.settings {
              acme_email = "/dev/null";
              tls_cert_path = "/dev/null";
              tls_key_path = "/dev/null";
              policy.path = "/dev/null";
              oidc.client_secret_path = "/dev/null";
            }
          );

          config_strict = true;
        };

        integration = {
          agent = {
            enabled = true;

            pre_authkey_path = pkgs.writeText "authKeyFile" secrets.headscale.preAuthKeys.headplane-agent;
          };

          proc.enabled = true;
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "headplane.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      virtualHosts."headplane.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/".extraConfig = ''
            rewrite ^/$ /admin last;
          '';

          "/admin" = {
            proxyPass = "http://127.0.0.1:${toString config.services.headplane.settings.server.port}/admin";
            basicAuth = secrets.nginx.basicAuth."headplane.00a.ch";

            extraConfig = ''
              satisfy any;

              allow 192.168.2.0/24;
              deny all;
            '';
          };
        };
      };
    };
  };
}
