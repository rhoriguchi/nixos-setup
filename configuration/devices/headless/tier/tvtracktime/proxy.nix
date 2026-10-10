{ config, pkgs, ... }:
let
  listen = [
    {
      addr = "127.0.0.1";
      port = config.services.nginx.defaultHTTPListenPort;
    }
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

          "= /sitemap.xml".alias = pkgs.writeText "sitemap.xml" ''
            <?xml version="1.0" encoding="UTF-8"?>
            <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              <url>
                <loc>https://tvtracktime.com</loc>
              </url>
            </urlset>
          '';

          "/api/".proxyPass = "http://${localAddress}:8080/";
          "/swagger-ui".proxyPass = "http://${localAddress}:8080";
          "/v3/api-docs".proxyPass = "http://${localAddress}:8080";

          "/previews/".proxyPass = "http://${localAddress}:3000";

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
