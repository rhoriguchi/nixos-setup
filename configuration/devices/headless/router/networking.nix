{ interfaces, lib, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;
  managementInterface = interfaces.management;

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    useNetworkd = true;
    useDHCP = false;

    enableIPv6 = false;
  };

  systemd.network = {
    enable = true;

    netdevs = {
      # Private
      "20-${internalInterface}.2" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "${internalInterface}.2";
        };
        vlanConfig.Id = 2;
      };

      # IoT
      "20-${internalInterface}.3" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "${internalInterface}.3";
        };
        vlanConfig.Id = 3;
      };

      # DMZ
      "20-${internalInterface}.10" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "${internalInterface}.10";
        };
        vlanConfig.Id = 10;
      };

      # Guest
      "20-${internalInterface}.100" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "${internalInterface}.100";
        };
        vlanConfig.Id = 100;
      };
    };

    networks = {
      "10-${externalInterface}" = {
        matchConfig.Name = externalInterface;
        networkConfig.DHCP = "ipv4";
        linkConfig.RequiredForOnline = "routable";
      };

      "10-${managementInterface}" = {
        matchConfig.Name = managementInterface;
        address = [ "172.16.1.1/24" ];
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };

      "10-${internalInterface}" = {
        matchConfig.Name = internalInterface;
        address = [ "${ips.router}/24" ];
        vlan = [ "${internalInterface}.2" "${internalInterface}.3" "${internalInterface}.10" "${internalInterface}.100" ];
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };

      "30-${internalInterface}.2" = {
        matchConfig.Name = "${internalInterface}.2";
        address = [ "192.168.2.1/24" ];
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };

      "30-${internalInterface}.3" = {
        matchConfig.Name = "${internalInterface}.3";
        address = [ "192.168.3.1/24" ];
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };

      "30-${internalInterface}.10" = {
        matchConfig.Name = "${internalInterface}.10";
        address = [ "192.168.10.1/24" ];
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };

      "30-${internalInterface}.100" = {
        matchConfig.Name = "${internalInterface}.100";
        address = [ "192.168.100.1/24" ];
        networkConfig.DHCP = false;
        linkConfig.RequiredForOnline = false;
      };
    };
  };

  services = {
    avahi = {
      enable = true;

      reflector = true;
      allowInterfaces = [ "${internalInterface}.2" "${internalInterface}.3" "${internalInterface}.10" ];
    };

    frr = {
      pimd.enable = true;

      config = ''
        ip pim rp ${ips.router} 224.0.1.0/24
        ip pim rp ${ips.router} 224.0.2.0/24
        ip pim rp ${ips.router} 239.0.0.0/8

        interface ${internalInterface}.2
          ip pim
          ip igmp

        interface ${internalInterface}.3
          ip pim
          ip igmp

        interface ${internalInterface}.10
          ip pim
          ip igmp
      '';
    };
  };
}
