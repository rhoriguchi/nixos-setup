{ config, pkgs, ... }:
let
  autheliaLocationFile = pkgs.writeText "location.conf" ''
    location /internal/authelia {
      internal;

      proxy_pass https://authelia.00a.ch/api/authz/auth-request;

      proxy_ssl_server_name on;
      proxy_ssl_name authelia.00a.ch;

      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header Content-Length "";
      proxy_set_header Connection "";

      proxy_pass_request_body off;
      proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
      proxy_redirect http:// $scheme://;
      proxy_http_version 1.1;
      proxy_cache_bypass $cookie_session;
      proxy_no_cache $cookie_session;
      proxy_buffers 4 32k;
      client_body_buffer_size 128k;
    }
  '';

  autheliaAuthFile = pkgs.writeText "auth.conf" ''
    auth_request /internal/authelia;

    error_page 401 =302 https://authelia.00a.ch/?rd=$scheme://$host$request_uri;
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /run/nginx-authelia 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
    "L+ /run/nginx-authelia/location.conf - - - - ${autheliaLocationFile}"
    "L+ /run/nginx-authelia/auth.conf - - - - ${autheliaAuthFile}"
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@00a.ch";
  };

  services = {
    nginx = {
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedUwsgiSettings = true;

      appendHttpConfig = ''
        add_header Referrer-Policy origin-when-cross-origin;
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options DENY;
      '';

      virtualHosts."_" = {
        default = true;
        rejectSSL = true;

        locations = {
          "@blackhole".return = 444;

          "/" = {
            return = 444;

            extraConfig = ''
              error_page 400 = @blackhole;
            '';
          };
        };
      };
    };

    logrotate.settings.nginx.enable = false;
  };
}
