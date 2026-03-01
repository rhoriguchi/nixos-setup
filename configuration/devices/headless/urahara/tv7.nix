{
  interfaces,
  lib,
  ...
}:
let
  externalInterface = interfaces.external;

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/urahara/dhcp/ips.nix");
in
{
  boot.kernel.sysctl."net.ipv4.conf.${externalInterface}.rp_filter" = 2;

  # TODO remove comments
  # > tcpdump -ni eth3.2 igmp -vvvv
  networking.nftables.tables.tv7 = {
    family = "ip";

    content = ''
      chain input {
        # Run before firewall input chain
        type filter hook input priority filter - 10;

        ip protocol { pim, igmp } accept

        ip daddr 233.50.230.0/24 udp dport 5000 accept
        # ip daddr 233.50.230.0/24 udp dport 4022 accept
      }

      chain forward {
        # Run before firewall input chain
        type filter hook forward priority filter - 10;

        ip protocol { pim, igmp } accept

        ip daddr 233.50.230.0/24 udp dport 5000 accept
        # ip daddr 233.50.230.0/24 udp dport 4022 accept
      }
    '';
  };

  services.frr = {
    pimd.enable = true;

    config = ''
      # ip pim ssm range 233.50.230.0/24
      # ip pim rp ${ips.urahara} 233.50.230.0/24

      interface ${externalInterface}
        ip pim
        ip igmp proxy
    '';
  };
}
