{
  interfaces,
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
    "net.ipv4.conf.${externalInterface}.rp_filter" = 0;
    "net.ipv4.conf.${internalInterface}.2.rp_filter" = 0;
    "net.ipv4.conf.${internalInterface}.3.rp_filter" = 0;
    "net.ipv4.conf.${internalInterface}.100.rp_filter" = 0;
  };

  networking.nftables.tables.tv7 = {
    family = "ip";

    content = ''
      chain input {
        # Run before `firewall` input chain
        type filter hook input priority filter - 10;

        ip protocol { pim, igmp } accept

        ip daddr 233.50.230.0/24 udp dport 5000 accept
      }

      chain forward {
        # Run before `firewall` forward chain
        type filter hook forward priority filter - 10;

        ip protocol { pim, igmp } accept

        ip daddr 233.50.230.0/24 udp dport 5000 accept
      }
    '';
  };

  services.frr = {
    pimd.enable = true;

    config = ''
      ip pim rp ${ips.urahara} 233.50.230.0/24

      interface ${externalInterface}
        ip pim
        ip igmp
        ip igmp proxy-service
    '';
  };
}
