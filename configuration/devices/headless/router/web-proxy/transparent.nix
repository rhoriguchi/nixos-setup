{ config, lib, pkgs, ... }: {
  networking = {
    iproute2 = {
      enable = true;

      rttablesExtraConfig = ''
        100 nginx-transparent
      '';
    };

    nftables = {
      enable = true;

      tables = {
        nginx-transparent-internal = {
          family = "inet";

          content = ''
            chain input {
              type filter hook input priority filter;

              fib daddr type local tcp dport ${toString config.services.nginx.defaultSSLListenPort} ct mark set 2 counter
              ${
                lib.optionalString config.services.lancache.enable
                "fib daddr type local tcp dport ${toString config.services.lancache.httpsPort} ct mark set 2 counter"
              }

              # ct mark 2 meta mark set 2 counter
            }

            chain output {
              type filter hook output priority filter;

              oif lo ct mark 2 meta mark set 2 counter
            }
          '';
        };

        nginx-transparent-external = {
          family = "inet";

          content = ''
            chain output {
              type filter hook output priority mangle;

              fib daddr type != local tcp dport 443 ct mark set 1
            }

            chain prerouting {
              type filter hook prerouting priority filter;

              ct mark 1 meta mark set 1
            }
          '';
        };
      };
    };
  };

  systemd.services = {
    nginx.serviceConfig = {
      CapabilityBoundingSet = [ "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_NET_RAW" ];
    };

    nginx-transparent = {
      after = [ "network.target" "nginx.service" ];

      script = ''
        ${pkgs.iproute2}/bin/ip rule add fwmark 1 lookup nginx-transparent
        ${pkgs.iproute2}/bin/ip route add local 0.0.0.0/0 dev lo table nginx-transparent
      '';

      preStop = ''
        ${pkgs.iproute2}/bin/ip route del local 0.0.0.0/0 dev lo table nginx-transparent
        ${pkgs.iproute2}/bin/ip rule del fwmark 1 lookup nginx-transparent
      '';

      serviceConfig.Type = "oneshot";
    };
  };

  services.nginx.stream.transparent = true;
}
