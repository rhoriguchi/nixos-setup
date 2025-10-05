{ config, secrets, ... }:
let
  hostname = "headscale.00a.ch";
in
{
  services = {
    headscale = {
      enable = true;

      settings = {
        server_url = "https://${hostname}";

        prefixes.allocation = "random";

        dns = {
          base_domain = "tailnet";
          override_local_dns = false;
        };

        # TODO needed?
        # oidc.allowed_users = ["tailnet"];

        # TODO
        # oidc:
        #   issuer: "https://sso.example.com"
        #   client_id: "headscale"
        #   client_secret: "generated-secret"
        #   expiry: 30d   # Use 0 to disable node expiration

        # TODO
        # derp
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        hostname
      ];
    };

    nginx = {
      enable = true;

      virtualHosts.${hostname} = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };
  };
}
