{ config, secrets, ... }:
let
  adguardhomePort = 80;

  routerIp = "192.168.1.1";

  settings = {
    users = [{
      name = secrets.adguard.username;
      password = secrets.adguard.encryptedUsernamePassword;
    }];
    dns = rec {
      bind_host = "0.0.0.0";
      bootstrap_dns = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
      upstream_dns = bootstrap_dns ++ [ "[/guest/]${routerIp}" "[/iot/]${routerIp}" "[/local/]${routerIp}" ];
      rewrites = map (domain: {
        inherit domain;
        answer = "XXLPitu-Server.local";
      }) [
        "deluge.00a.ch"
        "home-assistant.00a.ch"
        "home.00a.ch"
        "prowlarr.00a.ch"
        "sonarr.00a.ch"
        "tautulli.00a.ch"
        "wireguard.00a.ch"

        "price-tracker.00a.ch"
        "*.price-tracker.00a.ch"
      ];
    };
    schema_version = 14;
  };
in {
  imports = [ ../common.nix ];

  networking.hostName = "AdGuard";

  services = {
    nginx = {
      enable = true;

      # TODO add certificate
      virtualHosts."adguardhome" = {
        # TODO commented
        # useACMEHost = null;

        # enableSSL = true;
        # forceSSL = true;

        listen = [{
          addr = "0.0.0.0";
          port = adguardhomePort;
        }];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };

        extraConfig = ''
          allow 192.168.1.0/24;
          deny all;
        '';
      };
    };

    adguardhome = {
      enable = true;

      mutableSettings = false;
      inherit settings;
    };

    wireguard-vpn = {
      enable = true;

      type = "client";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 adguardhomePort ];
    allowedUDPPorts = [ 53 ];
  };
}
