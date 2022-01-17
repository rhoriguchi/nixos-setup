{ config, ... }:
let
  adguardhomePort = 80;

  settings = {
    users = [{
      name = "admin";
      password = (import ../../../../secrets.nix).services.adguardhome.admin.password;
    }];
    dns = {
      bind_hosts = [ config.services.adguardhome.host ];
      upstream_dns = let routerIp = "192.168.1.1";
      in [ "[/guest/]${routerIp}" "[/iot/]${routerIp}" "[/local/]${routerIp}" "tls://1dot1dot1dot1.cloudflare-dns.com" ];
      rewrites = [
        {
          domain = "xxlpitu-home.duckdns.org";
          # TODO get hostname from "configuration/devices/headless/server/default.nix"
          answer = "XXLPitu-Server.local";
        }
        {
          domain = "xxlpitu-hs.duckdns.org";
          # TODO get hostname from "configuration/devices/headless/server/default.nix"
          answer = "XXLPitu-Server.local";
        }
      ];
    };
    schema_version = 12;
  };
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

        listen = [{
          addr = "0.0.0.0";
          port = adguardhomePort;
        }];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };

        extraConfig = ''
          allow 192.168.1.0/16;
          deny all;
        '';
      };
    };

    adguardhome = {
      enable = true;

      mutableSettings = false;
      settings = settings;
    };
  };

  # TODO more ports needed? https://i.imgur.com/zFYaiyp.png
  networking.firewall = {
    allowedTCPPorts = [ 53 adguardhomePort ];
    allowedUDPPorts = [ 53 ];
  };
}
