{ config, secrets, ... }: {
  services = {
    nginx.virtualHosts."monitoring.00a.ch" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.monitoring.webPort}";
        basicAuth = secrets.nginx.basicAuth."monitoring.00a.ch";
      };

      extraConfig = ''
        satisfy any;

        allow 192.168.1.0/24;
        deny all;
      '';
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "monitoring.00a.ch" ];
    };

    monitoring = {
      enable = true;

      type = "parent";
      apiKey = secrets.monitoring.apiKey;
    };
  };
}
