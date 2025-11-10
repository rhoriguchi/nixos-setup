{
  config,
  secrets,
  ...
}:
{
  services = {
    netvisor.server = {
      enable = true;

      publicServerHostname = "netvisor.00a.ch";
      publicServerPort = 443;
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "netvisor.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      virtualHosts."netvisor.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.netvisor.server.port}";
          basicAuth = secrets.nginx.basicAuth."netvisor.00a.ch";

          extraConfig = ''
            satisfy any;

            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };
  };
}
