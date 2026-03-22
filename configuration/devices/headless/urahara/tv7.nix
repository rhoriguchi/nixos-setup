{
  interfaces,
  lib,
  libCustom,
  ...
}:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  ips = import (libCustom.relativeToRoot "configuration/devices/headless/urahara/dhcp/ips.nix");
in
{
  boot.kernel.sysctl = {
    # Force rp_filter to 0 globally to ensure per-interface settings are effective
    "net.ipv4.conf.all.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.default.rp_filter" = lib.mkForce 0;

    "net.ipv4.conf.${externalInterface}.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.${internalInterface}.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.${internalInterface}.2.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.${internalInterface}.3.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.${internalInterface}.10.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.${internalInterface}.100.rp_filter" = lib.mkForce 0;
  };

  networking.nftables.tables.tv7 = {
    family = "inet";

    content = ''
      chain prerouting {
        # Run before `nixos-fw` rpfilter
        type filter hook prerouting priority mangle - 100;

        ip protocol { pim, igmp } accept
      }

      chain input {
        # Run before `firewall` and `nixos-fw` input chains
        type filter hook input priority -100;

        ip protocol { pim, igmp } accept

        # IGMPv3 reports go to 224.0.0.22
        ip daddr 224.0.0.22 accept

        ip daddr 233.50.230.0/24 udp dport 5000 accept
      }

      chain forward {
        # Run before `firewall` forward chain
        type filter hook forward priority -100;

        ip protocol { pim, igmp } accept

        ip daddr 233.50.230.0/24 udp dport 5000 accept
      }
    '';
  };

  services.frr = {
    pimd.enable = true;

    config = ''
      # Support ASM and SSM for Init7 TV7
      ip pim rp ${ips.urahara} 233.50.230.0/24
      ip pim ssm prefix-list TV7-SSM
      ip prefix-list TV7-SSM permit 233.50.230.0/24

      # Static RPF to ensure pimd knows to pull from eth4
      ip mroute 0.0.0.0/0 ${externalInterface}

      interface ${externalInterface}
        ip pim
        ip igmp
        ip igmp version 3
        ip igmp proxy

      interface ${internalInterface}.2
        ip pim
        ip igmp
        ip igmp version 3

      interface ${internalInterface}.3
        ip pim
        ip igmp
        ip igmp version 3

      # Enable PIM on the interface holding the RP address (192.168.1.1)
      interface ${internalInterface}
        ip pim
    '';
  };
}
