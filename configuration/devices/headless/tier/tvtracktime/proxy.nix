{
  config,
  lib,
  pkgs,
  ...
}:
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

    appendHttpConfig = ''
      map $http_user_agent $tvtracktime_link_preview_bot {
        default 0;
        "~*(${
          lib.concatStringsSep "|" [
            "Applebot"
            "Cardyb"
            "Discordbot"
            "Embedly"
            "facebookexternalhit"
            "Facebot"
            "LinkedInBot"
            "Mastodon"
            "Pinterest/0.2"
            "Pinterestbot"
            "redditbot"
            "SkypeUriPreview"
            "Slackbot"
            "Synapse"
            "TelegramBot"
            "Twitterbot"
            "ViberBot"
            "WhatsApp"
          ]
        })" 1;
      }
    '';

    virtualHosts = {
      "tvtracktime.com" = {
        inherit listen;

        locations = {
          "/".proxyPass = "http://${localAddress}:80";

          "~ ^/series/(?<seriesId>[0-9]+)$" = {
            proxyPass = "http://${localAddress}:80";

            extraConfig = ''
              if ($tvtracktime_link_preview_bot) {
                rewrite ^ /api/link-preview/series/$seriesId last;
              }
            '';
          };

          "= /sitemap.xml".alias = pkgs.writeText "sitemap.xml" ''
            <?xml version="1.0" encoding="UTF-8"?>
            <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              <url>
                <loc>https://tvtracktime.com</loc>
              </url>
            </urlset>
          '';

          "/api/".proxyPass = "http://${localAddress}:8080/";
          "/api/metrics".return = 404;
          "= /api/health".return = 404;

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
