{
  config,
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

        integration = {
          agent = {
            enabled = true;

            pre_authkey_path = pkgs.writeText "authKeyFile" secrets.headscale.preAuthKeys.headplane-agent.key;
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

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations = {
          "/".extraConfig = ''
            rewrite ^/$ /admin last;
          '';

          "/admin" = {
            proxyPass = "http://127.0.0.1:${toString config.services.headplane.settings.server.port}/admin";

            extraConfig = ''
              include /run/nginx-authelia/auth.conf;
            '';
          };
        };
      };
    };
  };
}
