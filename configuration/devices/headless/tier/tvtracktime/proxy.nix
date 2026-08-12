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

  localAddress = config.containers.tvtracktime-application.localAddress;
in
{
  services.nginx = {
    enable = true;

    virtualHosts = {
      "tvtracktime.com" = {
        inherit listen;

        locations = {
          "/".proxyPass = "http://${localAddress}:80";

          "/api/".proxyPass = "http://${localAddress}:8080/";
          "/swagger-ui".proxyPass = "http://${localAddress}:8080";
          "/v3/api-docs".proxyPass = "http://${localAddress}:8080";

          "/s3/".proxyPass = "http://${localAddress}:8333/tvtracktime/";
        };
      };

      "www.tvtracktime.com" = {
        inherit listen;

        globalRedirect = "tvtracktime.com";
      };
    };
  };
}
