{ config, secrets, ... }:
let homeAssistantPort = 8123;
in {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "home-assistant.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts = let proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}";
      in {
        "home-assistant.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            inherit proxyPass;
            proxyWebsockets = true;

            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };

        "${config.networking.hostName}.local" = {
          listen = map (addr: {
            inherit addr;
            port = homeAssistantPort;
          }) config.services.nginx.defaultListenAddresses;

          locations."/api/webhook".proxyPass = proxyPass;
        };
      };
    };

    home-assistant.config.http = {
      server_port = homeAssistantPort + 1;
      trusted_proxies = "127.0.0.1";
      use_x_forwarded_for = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ homeAssistantPort ];
}
