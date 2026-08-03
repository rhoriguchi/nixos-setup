{
  networking.nftables.tables.tvtracktime = {
    family = "inet";

    content = ''
      set rfc1918 {
        type ipv4_addr;
        flags interval;
        elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 }
      }

      set rfc4193 {
        type ipv6_addr;
        flags interval;
        elements = { fc00::/7 }
      }

      chain input {
        type filter hook input priority filter; policy accept;

        ct state { established, related } accept

        iifname { ve-tvtracktime } meta l4proto { tcp, udp } th dport { 53 } accept

        iifname { ve-tvtracktime } drop
      }

      chain forward {
        type filter hook forward priority filter; policy accept;

        iifname { ve-tvtracktime } meta l4proto { tcp, udp } th dport { 53 } accept

        iifname { ve-tvtracktime } ip daddr @rfc1918 drop
        iifname { ve-tvtracktime } ip6 daddr @rfc4193 drop
      }
    '';
  };
}
