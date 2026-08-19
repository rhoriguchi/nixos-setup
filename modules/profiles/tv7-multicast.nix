{
  # https://www.init7.net/en/tv/channels
  networking.nftables.tables.tv7-multicast = {
    family = "inet";

    content = ''
      chain input {
        # Run after `nixos-fw` input chain, because of `networking.firewall.allowedUDPPorts`
        type filter hook input priority filter + 10;

        udp dport 5000 jump tv7-multicast-filter
      }

      chain tv7-multicast-filter {
        ip saddr 77.109.129.0/24 ip daddr 233.50.230.0/24 accept

        drop
      }
    '';
  };

  networking.firewall.allowedUDPPorts = [ 5000 ];
}
