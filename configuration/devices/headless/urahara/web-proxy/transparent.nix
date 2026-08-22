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

  mark = "72539956";
in
{
  boot.kernel.sysctl = lib.listToAttrs (
    map (
      interface:
      lib.nameValuePair "net.ipv4.conf.${lib.replaceStrings [ "." ] [ "/" ] interface}.rp_filter" 2
    ) internalInterfaces
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
            type route hook output priority mangle;

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
      ip rule del fwmark ${mark} lookup nginx-transparent 2>/dev/null || true
      ip rule add fwmark ${mark} lookup nginx-transparent
      ip route replace local 0.0.0.0/0 dev lo table nginx-transparent

      # Without an explicit route to each internal subnet, the table's
      # `local 0.0.0.0/0 dev lo` catch-all also matches nginx's own
      # outbound (spoofed source) connection to the upstream, sending it
      # to loopback instead of out over the wire. Copy the interfaces'
      # already-masked connected routes from the main table rather than
      # computing the network prefix ourselves.
      for interface in ${lib.concatMapStringsSep " " lib.escapeShellArg internalInterfaces}; do
        ip -4 -o route show dev "$interface" scope link proto kernel | while read -r prefix _; do
          ip route replace "$prefix" dev "$interface" table nginx-transparent
        done
      done
    '';

    preStop = ''
      for interface in ${lib.concatMapStringsSep " " lib.escapeShellArg internalInterfaces}; do
        ip -4 -o route show dev "$interface" scope link proto kernel | while read -r prefix _; do
          ip route del "$prefix" dev "$interface" table nginx-transparent 2>/dev/null || true
        done
      done

      ip route del local 0.0.0.0/0 dev lo table nginx-transparent 2>/dev/null || true
      ip rule del fwmark ${mark} lookup nginx-transparent 2>/dev/null || true
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  services.nginx.stream.transparent = true;
}
