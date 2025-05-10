{ config, ... }: {
  services = {
    lancache = {
      enable = true;

      cachedServices = [
        "blizzard"
        "epicgames"
        "nintendo"
        # TODO uncomment when https://github.com/uklans/cache-domains/issues/209 fixed
        # "riot"
        "steam"
        "wsus"
      ];
    };

    steam-lancache-prefill = {
      enable = true;

      apps = [
        105600 # Terraria
        1091500 # Cyberpunk 2077
        1353300 # Idle Slayer
        1366540 # Dyson Sphere Program
        1614550 # Astro Colony
        1794680 # Vampire Survivors
        2379780 # Balatro
        250900 # The Binding of Isaac: Rebirth
        427520 # Factorio
      ];
    };

    nginx = {
      enable = true;

      virtualHosts = {
        # Required for steam-lancache-prefill
        # https://github.com/tpill90/lancache-prefill-common/blob/01d2c6e29cffe1216046c88d778d38181c9acf40/dotnet/LancacheIpResolver.cs#L106-L123
        "_" = {
          listen = map (addr: {
            inherit addr;
            port = config.services.nginx.defaultHTTPListenPort;
          }) config.services.nginx.defaultListenAddresses;

          locations."/lancache-heartbeat" = {
            proxyPass = "http://127.0.0.1:${toString config.services.lancache.httpPort}/lancache-heartbeat";

            extraConfig = ''
              allow 192.168.0.0/16;
              deny all;
            '';
          };
        };

        "lancache" = {
          serverAliases = config.services.lancache.cacheDomains;

          listen = map (addr: {
            inherit addr;
            port = config.services.nginx.defaultHTTPListenPort;
          }) config.services.nginx.defaultListenAddresses;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.lancache.httpPort}";

            extraConfig = ''
              allow 192.168.0.0/16;
              deny all;
            '';
          };
        };
      };

      stream.upstreams.lancache = {
        server = "127.0.0.1:${toString config.services.lancache.httpsPort}";
        hostnames = config.services.lancache.cacheDomains;
      };
    };
  };
}
