{ config, ... }:
let homeAssistantPort = 8123;
in {
  services = {
    nginx = {
      enable = true;

      virtualHosts."home-assistant" = {
        # TODO HOME-ASSISTANT commented
        # forceSSL = true;
        # enableACME = true;

        # TODO HOME-ASSISTANT needed?
        serverAliases = [ "xxlpitu-hs.duckdns.org" ];

        extraConfig = ''
          proxy_buffering off;
        '';

        listen = [{
          addr = "0.0.0.0";
          port = homeAssistantPort;
        }];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}";
          proxyWebsockets = true;
        };
      };
    };

    home-assistant.config.http = {
      trusted_proxies = "127.0.0.1";
      use_x_forwarded_for = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ homeAssistantPort ];
}
