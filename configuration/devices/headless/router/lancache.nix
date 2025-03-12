{ config, ... }: {
  services = {
    lancache = {
      enable = true;

      cachedServices = [ "blizzard" "epicgames" "nintendo" "riot" "steam" "wsus" ];
    };

    nginx = {
      enable = true;

      virtualHosts."lancache" = {
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
  };
}
