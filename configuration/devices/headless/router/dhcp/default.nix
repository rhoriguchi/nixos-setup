{ interfaces, ... }:
let
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  ips = import ./ips.nix;
in {
  networking.firewall.interfaces = let
    rules.allowedUDPPorts = [
      67 # DHCP
    ];
  in {
    "${managementInterface}" = rules;

    "${internalInterface}" = rules;
    "${internalInterface}.2" = rules;
    "${internalInterface}.3" = rules;
    "${internalInterface}.10" = rules;
    "${internalInterface}.100" = rules;
  };

  services.dnsmasq = {
    enable = true;

    settings = {
      interface = [
        "${managementInterface}"

        "${internalInterface}"
        "${internalInterface}.2"
        "${internalInterface}.3"
        "${internalInterface}.10"
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
        "${internalInterface}.2, 192.168.2.2, 192.168.2.254, 1h"
        "${internalInterface}.3, 192.168.3.2, 192.168.3.254, 1h"
        "${internalInterface}.10, 192.168.10.2, 192.168.10.254, 1h"
        "${internalInterface}.100, 192.168.100.2, 192.168.100.254, 1h"
      ];

      # https://blog.abysm.org/2020/06/human-readable-dhcp-options-for-dnsmasq
      dhcp-option = [
        "${managementInterface}, option:router, 172.16.1.1"

        "${internalInterface}, option:router, 192.168.1.1"
        "${internalInterface}, option:dns-server, 192.168.1.1"
        "${internalInterface}, option:domain-name, local"

        "${internalInterface}.2, option:router, 192.168.2.1"
        "${internalInterface}.2, option:dns-server, 192.168.2.1"
        "${internalInterface}.2, option:domain-name, local"

        "${internalInterface}.3, option:router, 192.168.3.1"
        "${internalInterface}.3, option:dns-server, 192.168.3.1"
        "${internalInterface}.3, option:domain-name, local"

        "${internalInterface}.10, option:router, 192.168.10.1"
        "${internalInterface}.10, option:dns-server, 192.168.10.1"
        "${internalInterface}.10, option:domain-name, local"

        "${internalInterface}.100, option:router, 192.168.100.1"
        "${internalInterface}.100, option:dns-server, 192.168.100.1"
      ];

      dhcp-host = [
        "74:83:c2:74:90:b7, unifi, ${ips.cloudKey}"
        "c8:7f:54:03:bd:79, XXLPitu-Server, ${ips.server}"
        "dc:a6:32:da:9d:b3, XXLPitu-Ulquiorra, ${ips.ulquiorra}"

        # Stadler Form Karl
        "a8:80:55:9c:09:9b, 192.168.3.254"
      ];
    };
  };
}
