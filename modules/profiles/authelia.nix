{ config, pkgs, ... }:
let
  locationFile = pkgs.writeText "location.conf" ''
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
      proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
      proxy_redirect http:// $scheme://;
      proxy_http_version 1.1;
      proxy_cache_bypass $cookie_session;
      proxy_no_cache $cookie_session;
      proxy_buffers 4 32k;
      client_body_buffer_size 128k;
    }

    location @authelia_redirect {
      return 302 https://authelia.00a.ch/?rd=$scheme://$host$request_uri;
    }
  '';

  authFile = pkgs.writeText "auth.conf" ''
    auth_request /internal/authelia;

    error_page 401 403 = @authelia_redirect;
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /run/nginx-authelia 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
    "L+ /run/nginx-authelia/location.conf - - - - ${locationFile}"
    "L+ /run/nginx-authelia/auth.conf - - - - ${authFile}"
  ];
}
