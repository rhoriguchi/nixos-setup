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
        server.cookie_secret_path = pkgs.writeText "cookieSecret" secrets.headplane.cookieSecret;

        headscale = {
          # TODO can probably be removed in the future
          config_path = (pkgs.formats.yaml { }).generate "headscale.yml" (
            lib.recursiveUpdate config.services.headscale.settings {
              acme_email = "/dev/null";
              tls_cert_path = "/dev/null";
              tls_key_path = "/dev/null";
              policy.path = "/dev/null";
              oidc.client_secret_path = "/dev/null";
            }
          );
          # TODO if config_path comes from headscale
          # config_strict = false;
        };

        integration = {
          agent = {
            enabled = true;

            pre_authkey_path = pkgs.writeText "authKeyFile" secrets.headscale.preAuthKeys.headplane-agent;
          };
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
