{
  config,
  lib,
  secrets,
  ...
}:
let
  bindPort = config.services.bind.listenOnPort;
  webPort = 8080;
in
{
  # TODO
  # Block with Pi Hole all DoH domains https://github.com/hagezi/dns-blocklists/blob/main/domains/doh.txt
  # DNAT all DoH ips on firewall https://github.com/hagezi/dns-blocklists/blob/main/ips/doh.txt might break other stuff?

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
      hostnames = [ "ad-blocker.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."ad-blocker.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString webPort}";

          proxyWebsockets = true;

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;

            proxy_buffering off;
          '';
        };
      };
    };

    pihole-ftl = {
      enable = true;

      lists = [
        {
          enabled = true;

          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          type = "block";
          description = "HaGeZi Multi PRO";
        }
        {
          enabled = true;

          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          description = "Steven Black's HOSTS";
        }
      ];

      settings.dns = {
        upstreams = [ "127.0.0.1#${toString bindPort}" ];

        revServers = lib.pipe config.services.kea.dhcp4.settings.subnet4 [
          (lib.filter (subnet: lib.any (opt: opt.name == "domain-name") (subnet.option-data or [ ])))

          (map (
            subnet:
            let
              domainName = (lib.findFirst (opt: opt.name == "domain-name") null (subnet.option-data or [ ])).data;
            in
            "true,${subnet.subnet},127.0.0.1#${toString bindPort},${domainName}"
          ))
        ];

        cache.size = 0;

        rateLimit = {
          count = 0;
          interval = 0;
        };
      };
    };

    pihole-web = {
      enable = true;

      ports = [ webPort ];
      hostName = "ad-blocker.00a.ch";
    };
  };
}
