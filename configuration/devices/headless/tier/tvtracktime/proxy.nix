{ config, ... }:
let
  listen =
    map
      (addr: {
        inherit addr;
        port = config.services.nginx.defaultHTTPListenPort;
      })
      [
        "127.0.0.1"
        "[::1]"
      ];
in
{
  services.nginx = {
    enable = true;

    virtualHosts = {
      "tvtracktime.com" = {
        inherit listen;

        locations = {
          "/".proxyPass = "http://${config.containers.tvtracktime.localAddress}:80";

          "/api/".proxyPass = "http://${config.containers.tvtracktime.localAddress}:8080/";
          "/swagger-ui".proxyPass = "http://${config.containers.tvtracktime.localAddress}:8080";
          "/v3/api-docs".proxyPass = "http://${config.containers.tvtracktime.localAddress}:8080";
          "/s3/".proxyPass = "http://${config.containers.tvtracktime.localAddress}:8333/tvtracktime/";
        };
      };

      "www.tvtracktime.com" = {
        inherit listen;

        globalRedirect = "tvtracktime.com";
      };
    };
  };
}
