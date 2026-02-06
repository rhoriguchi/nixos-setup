{
  config,
  lib,
  secrets,
  ...
}:
{
  services = {
    nginx = {
      enable = true;

      virtualHosts."monitoring.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.monitoring.webPort}";

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;

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
  };
}
