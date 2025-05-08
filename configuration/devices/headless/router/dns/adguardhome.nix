{ config, pkgs, secrets, ... }: {
  services = {
    bind = {
      listenOn = [ "127.0.0.1" ];
      listenOnPort = 9053;

      listenOnIpv6 = [ "127.0.0.1" ];
      listenOnIpv6Port = 9053;
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "adguardhome.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."adguardhome.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
          basicAuth = secrets.nginx.basicAuth."adguardhome.00a.ch";

          extraConfig = ''
            proxy_buffering off;

            satisfy any;

            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };

    adguardhome = {
      enable = true;

      host = "127.0.0.1";

      mutableSettings = false;
      settings = assert pkgs.adguardhome.schema_version == 29; {
        dns = rec {
          bootstrap_dns = [ "127.0.0.1:9053" ];
          upstream_dns = bootstrap_dns;

          local_ptr_upstreams = [ "127.0.0.1:9053" ];

          cache_size = 0;
          ratelimit = 0;
        };

        # TODO BIND commented
        # filtering.rewrites = [
        #   # TODO BIND move all local resolution to bind zone file
        #   {
        #     domain = "unifi.local";
        #     answer = ips.cloudKey;
        #   }
        #   {
        #     domain = "winbox.local";
        #     answer = ips.wingoRouter;
        #   }
        #   {
        #     domain = "${config.networking.hostName}.local";
        #     answer = ips.router;
        #   }
        # ] ++ (map (domain: {
        #   inherit domain;
        #   # TODO uncomment when https://github.com/AdguardTeam/AdGuardHome/issues/7327 fixed
        #   # answer = "${config.networking.hostName}.local";
        #   answer = ips.router;
        # }) config.services.infomaniak.hostnames) ++ (map (domain: {
        #   inherit domain;
        #   answer = "XXLPitu-Ulquiorra.local";
        # }) [ "printer.00a.ch" "scanner.00a.ch" ]) ++ (map (domain: {
        #   inherit domain;
        #   answer = "XXLPitu-Server.local";
        # }) [
        #   "deluge.00a.ch"
        #   "esphome.00a.ch"
        #   "grafana.00a.ch"
        #   "home-assistant.00a.ch"
        #   "immich.00a.ch"
        #   "minecraft.00a.ch"
        #   "monitoring.00a.ch"
        #   "plex.00a.ch"
        #   "prometheus.00a.ch"
        #   "prowlarr.00a.ch"
        #   "rustdesk.00a.ch"
        #   "sonarr.00a.ch"
        #   "tautulli.00a.ch"
        # ]) ++ lib.optionals config.services.lancache.enable (map (cachedDomain: {
        #   domain = cachedDomain;
        #   # TODO uncomment when https://github.com/AdguardTeam/AdGuardHome/issues/7327 fixed
        #   # answer = "${config.networking.hostName}.local";
        #   answer = ips.router;
        # }) config.services.lancache.cacheDomains);
      };
    };
  };
}
