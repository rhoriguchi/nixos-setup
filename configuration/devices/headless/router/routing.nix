{ interfaces, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  cloudKeyIp = "192.168.1.2";
  serverIp = "192.168.2.2";
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    useDHCP = false;

    enableIPv6 = false;

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

      "${internalInterface}".ipv4.addresses = [{
        address = "192.168.1.1";
        prefixLength = 24;
      }];
      "${internalInterface}.1".ipv4.addresses = [{
        address = "192.168.1.1";
        prefixLength = 24;
      }];
      "${internalInterface}.2".ipv4.addresses = [{
        address = "192.168.2.1";
        prefixLength = 24;
      }];
      "${internalInterface}.3".ipv4.addresses = [{
        address = "192.168.3.1";
        prefixLength = 24;
      }];
      "${internalInterface}.100".ipv4.addresses = [{
        address = "192.168.100.1";
        prefixLength = 24;
      }];
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

      settings = {
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
          "${internalInterface}.3, option:dns-server, 1.1.1.1, 1.0.0.1"
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
      };
    };

    avahi = {
      enable = true;

      reflector = true;
      allowInterfaces = [ "${internalInterface}" "${internalInterface}.1" "${internalInterface}.2" "${internalInterface}.3" ];
    };
  };
}
