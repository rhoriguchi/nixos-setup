{ config, interfaces, lib, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");
in {
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;

    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
  };

  networking = {
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

          set dmz_vlan {
            type ipv4_addr;
            flags interval;
            elements = { 192.168.10.0/24 }
          }

          set guest_vlan {
            type ipv4_addr;
            flags interval;
            elements = { 192.168.100.0/24 }
          }

          chain forward {
            type filter hook forward priority filter; policy accept;

            iifname { ${
              lib.concatStringsSep ", "
              (lib.filter (interface: lib.hasPrefix internalInterface interface) config.networking.nat.internalInterfaces)
            } } jump lan-filter

            oifname ${config.networking.nat.externalInterface} meta l4proto { tcp, udp } th dport { 53, 853 } jump dns-filter
          }

          chain lan-filter {
            ip saddr @unifi_network ip daddr @unifi_network accept

            ip saddr @private_vlan ip daddr @unifi_network accept
            ip saddr @private_vlan ip daddr @private_vlan accept
            ip saddr @private_vlan ip daddr @iot_vlan accept
            ip saddr @private_vlan ip daddr ${ips.wingoRouter} accept

            ip saddr @iot_vlan ip daddr ${ips.server} tcp dport { 443 } accept # Home Assistant - Shelly
            ip saddr @iot_vlan ip daddr ${ips.server} tcp dport { 445 } accept # Samba
            ip saddr @iot_vlan ip daddr ${ips.server} udp dport { 4002 } accept # Home Assistant - Govee

            ip saddr @rfc1918 ip daddr ${ips.server} tcp dport { 80, 443 } accept

            ${
              let
                rules = map (forwardPort:
                  let
                    splits = lib.splitString ":" forwardPort.destination;
                    ip = lib.head splits;
                    port = lib.last splits;
                  in "ip saddr @rfc1918 ip daddr ${ip} ${forwardPort.proto} dport { ${port} } accept") config.networking.nat.forwardPorts;
              in lib.concatStringsSep "\n" rules
            }

            ip saddr ${ips.server} ip daddr @iot_vlan tcp dport { 80 } accept # Home Assistant - Shelly
            ip saddr ${ips.server} ip daddr @iot_vlan tcp dport { 443 } accept # Home Assistant - Hue
            ip saddr ${ips.server} ip daddr @iot_vlan tcp dport { 3232 } accept # ESPHome - OTA
            ip saddr ${ips.server} ip daddr @iot_vlan tcp dport { 6053 } accept # Home Assistant - ESPHome
            ip saddr ${ips.server} ip daddr @iot_vlan tcp dport { 6668 } accept # Home Assistant - Tuya
            ip saddr ${ips.server} ip daddr @iot_vlan tcp dport { 8000 } accept # Home Assistant - Apple HomeKit
            ip saddr ${ips.server} ip daddr @iot_vlan udp dport { 4003 } accept # Home Assistant - Govee

            ip saddr @rfc1918 ip daddr @rfc1918 ct state established accept

            ip saddr @rfc1918 ip daddr @rfc1918 drop
          }

          chain dns-filter {
            ${lib.optionalString config.virtualisation.docker.enable "iifname docker0 accept"}
            ${lib.optionalString config.virtualisation.podman.enable "iifname podman0 accept"}

            iifname ${managementInterface} accept

            reject
          }
        '';
      };
    };

    nat = {
      enable = true;

      inherit externalInterface;
      internalInterfaces = [
        managementInterface

        internalInterface
        "${internalInterface}.2"
        "${internalInterface}.3"
        "${internalInterface}.10"
        "${internalInterface}.100"
      ];

      forwardPorts = [
        # Minecraft
        {
          proto = "tcp";
          destination = "${ips.server}:25565";
          sourcePort = 25565;
        }

        # Plex
        {
          proto = "tcp";
          destination = "${ips.server}:32400";
          sourcePort = 32400;
        }

        # RustDesk
        {
          proto = "tcp";
          destination = "${ips.server}:21115";
          sourcePort = 21115;
        }
        {
          proto = "tcp";
          destination = "${ips.server}:21116";
          sourcePort = 21116;
        }
        {
          proto = "tcp";
          destination = "${ips.server}:21117";
          sourcePort = 21117;
        }
        {
          proto = "tcp";
          destination = "${ips.server}:21118";
          sourcePort = 21118;
        }
        {
          proto = "tcp";
          destination = "${ips.server}:21119";
          sourcePort = 21119;
        }
        {
          proto = "udp";
          destination = "${ips.server}:21116";
          sourcePort = 21116;
        }
      ];
    };
  };
}
