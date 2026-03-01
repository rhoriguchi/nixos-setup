{ config, pkgs, ... }:
{
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
        # TODO commented
        # nginx-transparent-internal = {
        #   family = "inet";

        #   content = ''
        #     chain input {
        #       type filter hook input priority filter;

        #       # TODO comment
        #       # meta skuid ${toString config.users.users.${config.services.nginx.user}.uid} \
        #       #   fib daddr type local \
        #       #   tcp dport 443 ct mark set 27
        #       fib daddr type local tcp dport ${toString config.services.nginx.defaultSSLListenPort} ct mark set 27 counter

        #       # ct mark 27 meta mark set 27 counter
        #     }

        #     chain output {
        #       type filter hook output priority filter;

        #       oif lo ct mark 27 meta mark set 27 counter
        #     }
        #   '';
        # };

        nginx-transparent-external = {
          family = "inet";

          content = ''
            chain output {
              type filter hook output priority mangle;

              # TODO comment
              # fib daddr type != local tcp dport 443 ct mark set 1
              meta skuid ${toString config.users.users.${config.services.nginx.user}.uid} \
                fib daddr type != local \
                tcp dport 443 ct mark set 1
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
      after = [
        "network.target"
        "nginx.service"
      ];

      script = ''
        ${pkgs.iproute2}/bin/ip rule add fwmark 1 lookup nginx-transparent
        # TODO commented
        # ${pkgs.iproute2}/bin/ip rule add fwmark 27 lookup nginx-transparent
        ${pkgs.iproute2}/bin/ip route add local 0.0.0.0/0 dev lo table nginx-transparent
      '';

      preStop = ''
        ${pkgs.iproute2}/bin/ip route del local 0.0.0.0/0 dev lo table nginx-transparent
        # TODO commented
        # ${pkgs.iproute2}/bin/ip rule del fwmark 27 lookup nginx-transparent
        ${pkgs.iproute2}/bin/ip rule del fwmark 1 lookup nginx-transparent
      '';

      serviceConfig = {
        Type = "oneshot";

        # TODO needed?
        RemainAfterExit = true;
      };
    };
  };

  services.nginx.stream.transparent = true;
}
