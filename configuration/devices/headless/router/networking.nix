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

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");
in
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking = {
    useDHCP = false;

    dhcpcd = {
      IPv6rs = false;
      extraConfig = ''
        interface ${externalInterface}
          ipv6rs
          ia_na 1
          ia_pd 2 ${
            lib.concatStringsSep " " (
              lib.imap0 (index: interface: "${interface}/${toString index}") internalInterfaces
            )
          }
      '';
    };

    vlans = {
      # Trusted
      "${internalInterface}.2" = {
        id = 2;
        interface = internalInterface;
      };

      # IoT
      "${internalInterface}.3" = {
        id = 3;
        interface = internalInterface;
      };

      # Surveillance
      "${internalInterface}.4" = {
        id = 4;
        interface = internalInterface;
      };

      # DMZ
      "${internalInterface}.10" = {
        id = 10;
        interface = internalInterface;
      };

      # Guest
      "${internalInterface}.100" = {
        id = 100;
        interface = internalInterface;
      };
    };

    # Calling bridge interface `br-management` fails
    bridges.br0.interfaces =
      lib.filter
        (
          interface:
          !(lib.elem interface [
            externalInterface
            internalInterface
          ])
        )
        [
          "eth0"
          "eth1"
          "eth2"
          "eth3"
          "eth4"
        ];

    interfaces = {
      "${externalInterface}".useDHCP = true;

      "${internalInterface}".ipv4.addresses = [
        {
          address = ips.router;
          prefixLength = 24;
        }
      ];
      "${internalInterface}.2".ipv4.addresses = [
        {
          address = "192.168.2.1";
          prefixLength = 24;
        }
      ];
      "${internalInterface}.3".ipv4.addresses = [
        {
          address = "192.168.3.1";
          prefixLength = 24;
        }
      ];
      "${internalInterface}.4".ipv4.addresses = [
        {
          address = "192.168.4.1";
          prefixLength = 24;
        }
      ];
      "${internalInterface}.10".ipv4.addresses = [
        {
          address = "192.168.10.1";
          prefixLength = 24;
        }
      ];
      "${internalInterface}.100".ipv4.addresses = [
        {
          address = "192.168.100.1";
          prefixLength = 24;
        }
      ];

      br0.ipv4.addresses = [
        {
          address = "172.16.1.1";
          prefixLength = 24;
        }
      ];
    };
  };

  services = {
    avahi = {
      enable = true;

      reflector = true;
      allowInterfaces = [
        "${internalInterface}.2"
        "${internalInterface}.3"
        "${internalInterface}.4"
        "${internalInterface}.10"
      ];
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

        interface ${internalInterface}.4
          ip pim
          ip igmp

        interface ${internalInterface}.10
          ip pim
          ip igmp
      '';
    };

    corerad = {
      enable = true;

      settings.interfaces = [
        {
          name = externalInterface;
          monitor = true;
        }
      ]
      ++ map (interface: {
        name = interface;
        advertise = true;

        prefix = [
          {
            on_link = false;
          }
        ];
      }) internalInterfaces;
    };
  };
}
