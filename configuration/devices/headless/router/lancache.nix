{ lib, config, ... }: {
  services = {
    lancache = {
      enable = true;

      cachedServices = [ "blizzard" "epicgames" "nintendo" "riot" "steam" ];
    };

    nginx = {
      enable = true;

      virtualHosts = lib.listToAttrs (map (cachedDomain:
        lib.nameValuePair cachedDomain {
          listen = map (addr: {
            inherit addr;
            port = config.services.nginx.defaultHTTPListenPort;
          }) config.services.nginx.defaultListenAddresses;

          locations."/".proxyPass = "http://127.0.0.1:${toString config.services.lancache.httpPort}";
        }) config.services.lancache.cacheDomains);
    };
  };
}
