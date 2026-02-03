{
  config,
  interfaces,
  lib,
  ...
}:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  internalInterfaces = lib.filter (interface: lib.hasPrefix internalInterface interface) (
    lib.attrNames config.networking.interfaces
  );

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/urahara/dhcp/ips.nix");
in
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;

    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;

    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;

    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };

  networking = {
    nftables = {
      enable = true;

      tables.firewall = {
        family = "inet";

        content = ''
          set management_network_interface {
            type ifname;
            elements = { ${internalInterface} }
          }

          set trusted_vlan_interface {
            type ifname;
            elements = { ${internalInterface}.2 }
          }

          set iot_vlan_interface {
            type ifname;
            elements = { ${internalInterface}.3 }
          }

          set dmz_vlan_interface {
            type ifname;
            elements = { ${internalInterface}.10 }
          }

          set guest_vlan_interface {
            type ifname;
            elements = { ${internalInterface}.100 }
          }

          set multicast_ipv4_address {
            type ipv4_addr;
            flags interval;
            elements = { 224.0.1.0/24, 224.0.2.0/24, 239.0.0.0/8 }
          }

          chain forward {
            type filter hook forward priority filter; policy accept;

            iifname { ${lib.concatStringsSep ", " internalInterfaces} } oifname { ${config.networking.nat.externalInterface} } jump lan-to-wan-filter
            iifname { ${config.networking.nat.externalInterface} } oifname { ${lib.concatStringsSep ", " internalInterfaces} } jump wan-to-lan-filter
            iifname { ${lib.concatStringsSep ", " internalInterfaces} } oifname { ${lib.concatStringsSep ", " internalInterfaces} } jump lan-to-lan-filter
          }

          chain wan-to-lan-filter {
            ct state { established, related } accept
            ct status dnat accept

            drop
          }

          chain lan-to-wan-filter {
            meta l4proto { tcp, udp } th dport { 53, 853 } jump dns-filter

            accept
          }

          chain lan-to-lan-filter {
            ct state { established, related } accept

            meta l4proto { tcp, udp } th dport { 5555 } accept # Resilio Sync
            tcp dport { 53317 } accept # LocalSend
            udp dport { 41641 } accept # Tailscale

            meta nfproto ipv4 jump lan-to-lan-ipv4
            meta nfproto ipv6 jump lan-to-lan-ipv6

            drop
          }

          chain lan-to-lan-ipv4 {
            ip daddr @multicast_ipv4_address accept

            iifname @management_network_interface oifname @management_network_interface accept

            iifname @trusted_vlan_interface oifname @management_network_interface accept
            iifname @trusted_vlan_interface oifname @trusted_vlan_interface accept
            iifname @trusted_vlan_interface oifname @iot_vlan_interface accept
            iifname @trusted_vlan_interface oifname @dmz_vlan_interface accept

            iifname @iot_vlan_interface ip daddr ${ips.tier} tcp dport { 443 } accept # Home Assistant - Shelly
            iifname @iot_vlan_interface ip daddr ${ips.tier} tcp dport { 445 } accept # Samba
            iifname @iot_vlan_interface ip daddr ${ips.tier} tcp dport { 8324, 32469 } accept # Plex
            iifname @iot_vlan_interface ip daddr ${ips.tier} udp dport { 1900 } accept # Plex
            iifname @iot_vlan_interface ip daddr ${ips.tier} udp dport { 4002 } accept # Home Assistant - Govee

            ip saddr ${ips.tier} oifname @iot_vlan_interface tcp dport { 80 } accept # Home Assistant - Shelly
            ip saddr ${ips.tier} oifname @iot_vlan_interface tcp dport { 443 } accept # Home Assistant - Hue
            ip saddr ${ips.tier} oifname @iot_vlan_interface tcp dport { 8000 } accept # Home Assistant - Apple HomeKit
            ip saddr ${ips.tier} oifname @iot_vlan_interface udp dport { 4003 } accept # Home Assistant - Govee

            ip daddr ${ips.tier} tcp dport { 80, 443 } accept # HTTP / HTTPS
            ip daddr ${ips.ulquiorra} tcp dport { 80, 443 } accept # HTTP / HTTPS

            ${
              let
                rules = map (
                  forwardPort:
                  let
                    splits = lib.splitString ":" forwardPort.destination;
                    ip = lib.head splits;
                    port = lib.last splits;
                  in
                  "ip daddr ${ip} ${forwardPort.proto} dport { ${port} } accept"
                ) config.networking.nat.forwardPorts;
              in
              lib.concatStringsSep "\n" rules
            }
          }

          chain lan-to-lan-ipv6 {
            drop
          }

          chain dns-filter {
            iifname { ${
              lib.concatStringsSep ", " (
                [ "br0" ]
                ++ lib.optional config.virtualisation.docker.enable "docker0"
                ++ lib.optional config.virtualisation.podman.enable "podman0"
              )
            } } accept

            reject
          }
        '';
      };
    };

    nat = {
      enable = true;

      inherit externalInterface;
      internalInterfaces = [ "br0" ] ++ internalInterfaces;

      forwardPorts = [
        # Minecraft
        {
          proto = "tcp";
          destination = "${ips.tier}:25565";
          sourcePort = 25565;
        }

        # Plex
        {
          proto = "tcp";
          destination = "${ips.tier}:32400";
          sourcePort = 32400;
        }

        # RustDesk
        {
          proto = "tcp";
          destination = "${ips.tier}:21115";
          sourcePort = 21115;
        }
        {
          proto = "tcp";
          destination = "${ips.tier}:21116";
          sourcePort = 21116;
        }
        {
          proto = "tcp";
          destination = "${ips.tier}:21117";
          sourcePort = 21117;
        }
        {
          proto = "tcp";
          destination = "${ips.tier}:21118";
          sourcePort = 21118;
        }
        {
          proto = "tcp";
          destination = "${ips.tier}:21119";
          sourcePort = 21119;
        }
        {
          proto = "udp";
          destination = "${ips.tier}:21116";
          sourcePort = 21116;
        }

        # Terraria
        {
          proto = "tcp";
          destination = "${ips.tier}:7777";
          sourcePort = 7777;
        }
        {
          proto = "udp";
          destination = "${ips.tier}:7777";
          sourcePort = 7777;
        }
      ];
    };
  };
}
