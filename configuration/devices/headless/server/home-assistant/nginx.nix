{ config, ... }:
let homeAssistantPort = 8123;
in {
  services = {
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
          };

          extraConfig = ''
            proxy_buffering off;
          '';
        };

        "${config.networking.hostName}.local" = {
          listen = [{
            addr = "0.0.0.0";
            port = homeAssistantPort;
          }];

          locations."/".proxyPass = proxyPass;
        };
      };
    };

    home-assistant.config.http = {
      server_port = 8124;
      trusted_proxies = "127.0.0.1";
      use_x_forwarded_for = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ homeAssistantPort ];
}
