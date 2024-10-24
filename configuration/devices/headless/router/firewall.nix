{ lib, interfaces, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  wingoRouterIp = "192.168.0.254";
  serverIp = "192.168.2.2";
in {
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
          }
        '';
      };
    };

    nat = {
      enable = true;

      inherit externalInterface;
      internalInterfaces =
        [ "${internalInterface}" "${internalInterface}.1" "${internalInterface}.2" "${internalInterface}.3" "${internalInterface}.100" ];

      forwardPorts = [
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
