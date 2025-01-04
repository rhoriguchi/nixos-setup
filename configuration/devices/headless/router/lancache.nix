{ config, lib, ... }: {
  services = {
    lancache = {
      enable = true;

      cachedServices = [ "blizzard" "epicgames" "nintendo" "riot" "steam" "wsus" ];
    };

    nginx = {
      enable = true;

      virtualHosts = lib.listToAttrs (map (cachedDomain:
        lib.nameValuePair cachedDomain {
          listen = map (addr: {
            inherit addr;
            port = config.services.nginx.defaultHTTPListenPort;
          }) config.services.nginx.defaultListenAddresses;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.lancache.httpPort}";

            extraConfig = ''
              allow 10.0.0.0/8;
              allow 172.16.0.0/12;
              allow 192.168.0.0/16;
              deny all;
            '';
          };
        }) config.services.lancache.cacheDomains);
    };
  };
}
