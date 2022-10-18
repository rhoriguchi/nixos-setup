{ secrets, ... }: {
  security.acme.certs = let email = "contact@price-tracker.00a.ch";
  in {
    "api.price-tracker.00a.ch".email = email;
    "grafana.price-tracker.00a.ch".email = email;
    "price-tracker.00a.ch".email = email;
    "traefik.price-tracker.00a.ch".email = email;
    "www.price-tracker.00a.ch".email = email;
  };

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "api.price-tracker.00a.ch"
        "grafana.price-tracker.00a.ch"
        "price-tracker.00a.ch"
        "traefik.price-tracker.00a.ch"
        "www.price-tracker.00a.ch"
      ];
    };

    nginx = let proxyPass = "http://127.0.0.1:33850";
    in {
      enable = true;

      virtualHosts = {
        "api.price-tracker.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            inherit proxyPass;
            proxyWebsockets = true;
          };
        };
        "grafana.price-tracker.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/".proxyPass = proxyPass;
        };
        "price-tracker.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/".proxyPass = proxyPass;
        };
        "traefik.price-tracker.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/".proxyPass = proxyPass;
        };
        "www.price-tracker.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            inherit proxyPass;
            return = "301 https://price-tracker.00a.ch$request_uri";
          };
        };
      };
    };
  };
}
