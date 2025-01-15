{ config, interfaces, lib, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  ipv6Prefix = "fdc7:643d:1406";

  cloudKeyIp = "192.168.1.2";
  serverIp = "192.168.2.2";
in {
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  } // lib.optionalAttrs config.networking.enableIPv6 { "net.ipv6.conf.all.forwarding" = 1; };

  networking = {
    useDHCP = false;

    vlans = {
      # Private
      "${internalInterface}.1" = {
        id = 1;
        interface = internalInterface;
      };

      # DMZ
      "${internalInterface}.2" = {
        id = 2;
        interface = internalInterface;
      };

      # IoT
      "${internalInterface}.3" = {
        id = 3;
        interface = internalInterface;
      };

      # Guest
      "${internalInterface}.100" = {
        id = 100;
        interface = internalInterface;
      };
    };

    interfaces = {
      "${externalInterface}".useDHCP = true;

      "${managementInterface}".ipv4.addresses = [{
        address = "172.16.1.1";
        prefixLength = 24;
      }];

      "${internalInterface}" = {
        ipv4.addresses = [{
          address = "192.168.1.1";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "${ipv6Prefix}:1::1";
          prefixLength = 64;
        }];
      };
      "${internalInterface}.1" = {
        ipv4.addresses = [{
          address = "192.168.1.1";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "${ipv6Prefix}:1::1";
          prefixLength = 64;
        }];
      };
      "${internalInterface}.2" = {
        ipv4.addresses = [{
          address = "192.168.2.1";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "${ipv6Prefix}:2::1";
          prefixLength = 64;
        }];
      };
      "${internalInterface}.3" = {
        ipv4.addresses = [{
          address = "192.168.3.1";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "${ipv6Prefix}:3::1";
          prefixLength = 64;
        }];
      };
      "${internalInterface}.100" = {
        ipv4.addresses = [{
          address = "192.168.100.1";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "${ipv6Prefix}:100::1";
          prefixLength = 64;
        }];
      };
    };

    firewall.interfaces = let
      rules = {
        allowedUDPPorts = [
          67 # DHCP
        ];
      };
    in {
      "${managementInterface}" = rules;

      "${internalInterface}" = rules;
      "${internalInterface}.1" = rules;
      "${internalInterface}.2" = rules;
      "${internalInterface}.3" = rules;
      "${internalInterface}.100" = rules;
    };
  };

  services = {
    dnsmasq = {
      enable = true;

      settings = lib.mkMerge [
        {
          port = 9053;

          interface = [
            "${managementInterface}"

            "${internalInterface}"
            "${internalInterface}.1"
            "${internalInterface}.2"
            "${internalInterface}.3"
            "${internalInterface}.100"
          ];

          # enable hostname dns resolution
          expand-hosts = true;
          domain = "local";
          local = "/local/";

          dhcp-authoritative = true;
          dhcp-range = [
            "${managementInterface}, 172.16.1.2, 172.16.1.254, 1h"

            "${internalInterface}, 192.168.1.2, 192.168.1.254, 1h"
            "${internalInterface}.1, 192.168.1.2, 192.168.1.254, 1h"
            "${internalInterface}.2, 192.168.2.2, 192.168.2.254, 1h"
            "${internalInterface}.3, 192.168.3.2, 192.168.3.254, 1h"
            "${internalInterface}.100, 192.168.100.2, 192.168.100.254, 1h"
          ];

          # https://blog.abysm.org/2020/06/human-readable-dhcp-options-for-dnsmasq
          dhcp-option = [
            "${managementInterface}, option:router, 172.16.1.1"
            "${internalInterface}, option:router, 192.168.1.1"
            "${internalInterface}, option:dns-server, 192.168.1.1"
            "${internalInterface}, option:domain-name, local"

            "${internalInterface}.1, option:router, 192.168.1.1"
            "${internalInterface}.1, option:dns-server, 192.168.1.1"
            "${internalInterface}.1, option:domain-name, local"

            "${internalInterface}.2, option:router, 192.168.2.1"
            "${internalInterface}.2, option:dns-server, 192.168.2.1"
            "${internalInterface}.2, option:domain-name, local"

            "${internalInterface}.3, option:router, 192.168.3.1"
            "${internalInterface}.3, option:dns-server, 192.168.3.1"
            "${internalInterface}.3, option:domain-name, local"

            "${internalInterface}.100, option:router, 192.168.100.1"
            "${internalInterface}.100, option:dns-server, 192.168.100.1"
          ];

          dhcp-host = [
            "74:83:c2:74:90:b7, unifi, ${cloudKeyIp}"
            "c8:7f:54:03:bd:79, XXLPitu-Server, ${serverIp}"

            # Stadler Form Karl
            "a8:80:55:9c:09:9b, 192.168.3.254"
          ];
        }

        (lib.optionalAttrs config.networking.enableIPv6 {
          enable-ra = true;
          quiet-ra = true;

          ra-param = [
            "${internalInterface}, high, 60"
            "${internalInterface}.1, high, 60"
            "${internalInterface}.2, high, 60"
            "${internalInterface}.3, high, 60"
            "${internalInterface}.100, high, 60"
          ];

          # TODO `ra-names` needed / wanted? since ipv6 traffic between devices is forbidden
          # ra-names enables a mode which gives DNS names to dual-stack hosts which do ra-only for IPv6. Dnsmasq uses the host's IPv4 lease
          # to derive the name, network segment and MAC address and assumes that the host will also have an IPv6 address calculated using
          # the ra-only algorithm, on the same network segment. The address is pinged, and if a reply is received, an AAAA record is added to
          # the DNS for this IPv6 address. Note that this is only happens for directly-connected networks, (not one doing DHCP via a relay)
          # and it will not work if a host is using privacy extensions. ra-names can be combined with ra-stateless and ra-only.
          dhcp-range = [
            "${internalInterface}, ${ipv6Prefix}:1::2, ${ipv6Prefix}:1::ffff, slaac, 64, 1h"
            "${internalInterface}.1, ${ipv6Prefix}:1::2, ${ipv6Prefix}:1::ffff, slaac, 64, 1h"
            "${internalInterface}.2, ${ipv6Prefix}:2::2, ${ipv6Prefix}:2::ffff, slaac, 64, 1h"
            "${internalInterface}.3, ${ipv6Prefix}:3::2, ${ipv6Prefix}:3::ffff, slaac, 64, 1h"
            "${internalInterface}.100, ${ipv6Prefix}:100::2, ${ipv6Prefix}:100::ffff, slaac, 64, 1h"
          ];

          # https://blog.abysm.org/2020/06/human-readable-dhcp-options-for-dnsmasq
          dhcp-option = [
            # "${internalInterface}, option6:router, ${ipv6Prefix}:1::1"
            "${internalInterface}, option6:dns-server, ${ipv6Prefix}:1::1"

            # "${internalInterface}.1, option6:router, ${ipv6Prefix}:1::1"
            "${internalInterface}.1, option6:dns-server, ${ipv6Prefix}:1::1"

            # "${internalInterface}.2, option6:router, ${ipv6Prefix}:2::1"
            "${internalInterface}.2, option6:dns-server, ${ipv6Prefix}:2::1"

            # "${internalInterface}.3, option6:router, ${ipv6Prefix}:3::1"
            "${internalInterface}.3, option6:dns-server, ${ipv6Prefix}:3::1"

            # "${internalInterface}.100, option6:router, ${ipv6Prefix}:100::1"
            "${internalInterface}.100, option6:dns-server, ${ipv6Prefix}:100::1"
          ];
        })
      ];
    };

    avahi = {
      enable = true;

      reflector = true;
      allowInterfaces = [ "${internalInterface}" "${internalInterface}.1" "${internalInterface}.2" "${internalInterface}.3" ];
    };

    frr = {
      pimd.enable = true;

      config = ''
        ip pim rp 192.168.1.1 224.0.1.0/24
        ip pim rp 192.168.1.1 224.0.2.0/24
        ip pim rp 192.168.1.1 239.0.0.0/8

        interface ${internalInterface}
          ip pim
          ip igmp

        interface ${internalInterface}.1
          ip pim
          ip igmp

        interface ${internalInterface}.2
          ip pim
          ip igmp

        interface ${internalInterface}.3
          ip pim
          ip igmp
      '';
    };
  };
}
