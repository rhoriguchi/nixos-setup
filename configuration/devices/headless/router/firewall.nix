{ interfaces, lib, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  wingoRouterIp = "192.168.0.254";
  cloudKeyIp = "192.168.1.2";
  serverIp = "192.168.10.2";
in {
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;

    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
  };

  networking = {
    firewall.interfaces = let rules = { allowedTCPPorts = [ 80 443 ]; };
    in {
      "${externalInterface}" = rules;

      "${managementInterface}" = rules;

      "${internalInterface}" = rules;
      "${internalInterface}.2" = rules;
      "${internalInterface}.3" = rules;
      "${internalInterface}.10" = rules;
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

          set unifi_network {
            type ipv4_addr;
            flags interval;
            elements = { 192.168.1.0/24 }
          }

          set private_vlan {
            type ipv4_addr;
            flags interval;
            elements = { 192.168.2.0/24 }
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
                "${internalInterface}.2"
                "${internalInterface}.3"
                "${internalInterface}.10"
                "${internalInterface}.100"
              ]
            }" } jump lan
          }

          chain lan {
            ip saddr @unifi_network ip daddr @unifi_network accept
            ip saddr @unifi_network ip daddr @private_vlan ct state established accept

            ip saddr @private_vlan ip daddr @rfc1918 accept

            ip saddr @iot_vlan ip daddr ${serverIp} accept
            ip saddr @iot_vlan ip daddr @private_vlan ct state established accept

            ip saddr @guest_vlan ip daddr ${serverIp} tcp dport { 80, 443 } accept # Nginx
            ip saddr @guest_vlan ip daddr ${serverIp} tcp dport { 25565 } accept # Minecraft
            ip saddr @guest_vlan ip daddr ${serverIp} tcp dport { 32400 } accept # Plex

            ip saddr ${wingoRouterIp} ip daddr @private_vlan ct state established accept

            ip saddr ${cloudKeyIp} ip daddr @private_vlan ct state established accept

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
        [ "${internalInterface}" "${internalInterface}.2" "${internalInterface}.3" "${internalInterface}.10" "${internalInterface}.100" ];

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
