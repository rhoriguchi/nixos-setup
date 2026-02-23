{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  services = {
    bind = {
      listenOn = lib.mkForce [ "127.0.0.1" ];
      listenOnPort = 9053;

      listenOnIpv6 = lib.mkForce [ "::1" ];
      listenOnIpv6Port = 9053;
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "adguardhome.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."adguardhome.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";

          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;

            include /run/nginx-authelia/auth.conf;
          '';
        };
      };
    };

    adguardhome = {
      enable = true;

      host = "127.0.0.1";

      mutableSettings = false;
      settings =
        assert pkgs.adguardhome.schema_version == 32;
        {
          dns = rec {
            bootstrap_dns = [ "127.0.0.1:${toString config.services.bind.listenOnPort}" ];
            upstream_dns = bootstrap_dns;

            local_ptr_upstreams = [ "127.0.0.1:${toString config.services.bind.listenOnPort}" ];

            cache_enabled = false;
            cache_optimistic = false;
            ratelimit = 0;
          };
        };
    };
  };
}
