{ config, interfaces, lib, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  ipv6Prefix = "fdc7:643d:1406";

  wingoRouterIp = "192.168.0.254";
  serverIp = "192.168.2.2";
in {
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;

    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
  } // lib.optionalAttrs config.networking.enableIPv6 {
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };

  networking = {
    firewall.interfaces = let rules = { allowedTCPPorts = [ 80 443 ]; };
    in {
      "${externalInterface}" = rules;

      "${managementInterface}" = rules;

      "${internalInterface}" = rules;
      "${internalInterface}.1" = rules;
      "${internalInterface}.2" = rules;
      "${internalInterface}.3" = rules;
      "${internalInterface}.100" = rules;
    };

    nftables = {
      enable = true;

      tables.firewall = {
        family = "inet";

        content = ''
          set rfc1918 {
            type ipv4_addr;
            flags interval;
            elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 }
          }

          set private_vlan {
            type ipv4_addr;
            flags interval;
            elements = { 192.168.1.0/24 }
          }

          set iot_vlan {
            type ipv4_addr;
            flags interval;
            elements = { 192.168.3.0/24 }
          }

          set guest_vlan {
            type ipv4_addr;
            flags interval;
            elements = { 192.168.100.0/24 }
          }

          chain interface-filter-fw {
            type filter hook forward priority filter; policy accept;

            iifname { "${
              lib.concatStringsSep ''", "'' [
                "${internalInterface}"
                "${internalInterface}.1"
                "${internalInterface}.2"
                "${internalInterface}.3"
                "${internalInterface}.100"
              ]
            }" } jump lan
          }

          chain lan {
            ip saddr @private_vlan ip daddr ${wingoRouterIp} accept
            ip saddr @private_vlan ip daddr ${serverIp} accept
            ip saddr @private_vlan ip daddr @private_vlan accept
            ip saddr @private_vlan ip daddr @iot_vlan accept

            ip saddr @iot_vlan ip daddr ${serverIp} accept
            ip saddr @iot_vlan ip daddr @private_vlan ct state established accept

            ip saddr @guest_vlan ip daddr ${serverIp} tcp dport { 80, 443 } accept

            ip saddr ${serverIp} ip daddr @private_vlan ct state established accept
            ip saddr ${serverIp} ip daddr @guest_vlan ct state established accept
            ip saddr ${serverIp} ip daddr @iot_vlan accept

            ip saddr @rfc1918 ip daddr @rfc1918 drop

            ${
              lib.optionalString config.networking.enableIPv6 ''
                # TODO check if accept rules are needed, if needed can be generated out of `networking.interfaces.<name>.ipv6.addresses`
                # ip6 daddr ${ipv6Prefix}:1::1 accept
                # ip6 daddr ${ipv6Prefix}:2::1 accept
                # ip6 daddr ${ipv6Prefix}:3::1 accept
                # ip6 daddr ${ipv6Prefix}:100::1 accept

                # TODO commented
                # ip6 saddr ${ipv6Prefix}::/48 ip6 daddr ${ipv6Prefix}::/48 drop
              ''
            }
          }
        '';
      };
    };

    nat = {
      enable = true;

      inherit externalInterface;
      internalInterfaces =
        [ "${internalInterface}" "${internalInterface}.1" "${internalInterface}.2" "${internalInterface}.3" "${internalInterface}.100" ];

      enableIPv6 = config.networking.enableIPv6;
      internalIPv6s = [ "${ipv6Prefix}:1::/64" "${ipv6Prefix}:2::/64" "${ipv6Prefix}:3::/64" "${ipv6Prefix}:100::/64" ];

      forwardPorts = [
        # Minecraft
        {
          proto = "tcp";
          destination = "${serverIp}:25565";
          sourcePort = 25565;
        }

        # Plex
        {
          proto = "tcp";
          destination = "${serverIp}:32400";
          sourcePort = 32400;
        }
      ];
    };
  };
}
