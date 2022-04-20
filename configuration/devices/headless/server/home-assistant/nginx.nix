{ config, ... }:
let homeAssistantPort = 8123;
in {
  services = {
    nginx = {
      enable = true;

      virtualHosts."home-assistant.00a.ch" = {
        # TODO HOME-ASSISTANT commented
        # useACMEHost = null;

        # enableSSL = true;
        # forceSSL = true;

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

  # TODO HOME-ASSISTANT commented
  # security.acme.certs."home-assistant.00a.ch".dnsProvider = "XXXXXX";

  networking.firewall.allowedTCPPorts = [ homeAssistantPort ];
}
