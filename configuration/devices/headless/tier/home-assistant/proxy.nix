{ config, secrets, ... }:
{
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "home-assistant.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."home-assistant.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };

    home-assistant.config.http = {
      trusted_proxies = [ "127.0.0.1" ];
      use_x_forwarded_for = true;
    };
  };
}
