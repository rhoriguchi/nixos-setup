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
        headscale.api_key_path = pkgs.writeText "apiKey" secrets.headscale.apiKey;

        server = {
          cookie_secret_path = pkgs.writeText "cookieSecret" secrets.headplane.cookieSecret;

          proxy_auth.enabled = true;
        };

        integration = {
          agent.enabled = true;
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
        acmeRoot = null;
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

              proxy_set_header Remote-User $authelia_user;
              proxy_set_header Remote-Email $authelia_email;
              proxy_set_header Remote-Name $authelia_name;
            '';
          };
        };
      };
    };
  };
}
