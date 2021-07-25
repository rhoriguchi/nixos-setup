{ config, ... }:
let adGuardPort = 80;
in {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-AdGuard";

  services = {
    nginx = {
      enable = true;

      virtualHosts."adguardhome" = {
        # TODO commented
        # forceSSL = true;
        # enableACME = true;

        # TODO only allow request from local network

        listen = [{
          addr = "0.0.0.0";
          port = adGuardPort;
        }];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };
      };
    };

    adguardhome.enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 adGuardPort ];
    allowedUDPPorts = [ 53 ];
  };
}
