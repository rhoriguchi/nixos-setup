{ lib, secrets, ... }:
let ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");
in {
  imports = [ ../common.nix ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    hostName = "XXLPitu-Tier";

    interfaces.eth0 = {
      useDHCP = lib.mkForce false;

      ipv4.addresses = [{
        address = ips.tier;
        prefixLength = 24;
      }];
    };

    wireless = {
      enable = true;

      networks.Niflheim = secrets.wifis.Niflheim;
    };

    nat = {
      enable = true;

      externalInterface = "wlan0";
      internalInterfaces = [ "eth0" ];
    };

    firewall.interfaces.eth0.allowedUDPPorts = [
      67 # DHCP
    ];

    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    extraHosts = ''
      172.16.0.2 wireguard.00a.ch
    '';
  };

  services.dnsmasq = {
    enable = true;

    settings = {
      interface = "eth0";

      dhcp-authoritative = true;
      dhcp-range = [ "172.16.0.2, 172.16.0.254" ];
      dhcp-option = [ "option:router, ${ips.tier}" ];

      dhcp-host = [ "00:f0:cb:fe:c1:d4, XXLPitu-Router, 172.16.0.2" ];
    };
  };
}
