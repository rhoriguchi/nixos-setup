{
  config,
  interfaces,
  lib,
  pkgs,
  ...
}:
let
  internalInterface = interfaces.internal;

  internalInterfaces = lib.pipe config.networking.interfaces [
    lib.attrNames
    (lib.filter (interface: lib.hasPrefix internalInterface interface))
  ];

  mark = "59";
in
{
  boot.kernel.sysctl = lib.listToAttrs (
    map (interface: lib.nameValuePair "net.ipv4.conf.${interface}.rp_filter" 2) internalInterfaces
  );

  networking = {
    iproute2 = {
      enable = true;

      rttablesExtraConfig = ''
        ${mark} nginx-transparent
      '';
    };

    nftables = {
      enable = true;

      tables.nginx-transparent = {
        family = "inet";

        content = ''
          chain output {
            type filter hook output priority mangle;

            meta skuid ${toString config.users.users.${config.services.nginx.user}.uid} \
              fib daddr type != local \
              tcp dport 443 \
              ct mark set ${mark}
          }

          chain prerouting {
            type filter hook prerouting priority mangle;

            ct mark ${mark} \
              tcp sport 443 \
              meta mark set ${mark}
          }
        '';
      };
    };
  };

  systemd.services.nginx-transparent = {
    wants = [ config.systemd.services.nginx.name ];
    after = [ config.systemd.services.nginx.name ];
    wantedBy = [ "network-online.target" ];

    path = [ pkgs.iproute2 ];

    script = ''
      ip rule add fwmark ${mark} lookup nginx-transparent

      ip route add local 0.0.0.0/0 dev lo table nginx-transparent
      ${lib.optionalString config.networking.enableIPv6 "ip -6 route add local ::/0 dev lo table nginx-transparent"}
    '';

    preStop = ''
      ${lib.optionalString config.networking.enableIPv6 "ip -6 route del local ::/0 dev lo table nginx-transparent"}
      ip route del local 0.0.0.0/0 dev lo table nginx-transparent

      ip rule del fwmark ${mark} lookup nginx-transparent
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  services.nginx.stream.transparent = true;
}
