{ config, interfaces, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  download = 65;
  upload = 24;

  tags = {
    dns = "101";
    icmp = "102";
    plex = "103";
    resilio = "104";
    steam = "105";
    torrent = "106";
    wifi-calling = "107";
    wireguard = "108";

    private-vlan = "201";
    dmz-vlan = "202";
    iot-vlan = "203";
    guest-vlan = "204";
  };
in {
  networking.nftables = {
    enable = true;

    tables.qos = {
      family = "inet";

      content = ''
        chain interface-filter-fw {
          type filter hook forward priority filter; policy accept;

          iifname "${externalInterface}" oifname "${internalInterface}" jump tag-traffic
          iifname "${internalInterface}" oifname "${externalInterface}" jump tag-traffic
        }

        chain tag-traffic {
          ip daddr 192.168.1.0/24 mark set ${tags.private-vlan}
          ip saddr 192.168.1.0/24 mark set ${tags.private-vlan}

          ip daddr 192.168.2.0/24 mark set ${tags.dmz-vlan}
          ip saddr 192.168.2.0/24 mark set ${tags.dmz-vlan}

          ip daddr 192.168.3.0/24 mark set ${tags.iot-vlan}
          ip saddr 192.168.3.0/24 mark set ${tags.iot-vlan}

          ip daddr 192.168.100.0/24 mark set ${tags.guest-vlan}
          ip saddr 192.168.100.0/24 mark set ${tags.guest-vlan}


          meta l4proto { udp, tcp } th sport 53 mark set ${tags.dns}
          meta l4proto { udp, tcp } th dport 53 mark set ${tags.dns}

          ip protocol icmp mark set ${tags.icmp}

          meta l4proto tcp th dport 32400 mark set ${tags.plex}
          meta l4proto tcp th sport 32400 mark set ${tags.plex}

          meta l4proto tcp th dport 5555 mark set ${tags.resilio}
          meta l4proto tcp th sport 5555 mark set ${tags.resilio}

          meta l4proto { tcp, udp } th dport 27015-27050 mark set ${tags.steam}
          meta l4proto { tcp, udp } th sport 27015-27050 mark set ${tags.steam}

          meta l4proto tcp th dport 6881-6999 mark set ${tags.torrent}
          meta l4proto tcp th sport 6881-6999 mark set ${tags.torrent}

          meta l4proto tcp th dport 143 mark set ${tags.wifi-calling}
          meta l4proto tcp th sport 143 mark set ${tags.wifi-calling}
          meta l4proto udp th dport { 500, 4500 } mark set ${tags.wifi-calling}
          meta l4proto udp th sport { 500, 4500 } mark set ${tags.wifi-calling}

          meta l4proto udp th dport 51820 mark set ${tags.wireguard}
          meta l4proto udp th sport 51820 mark set ${tags.wireguard}
        }
      '';
    };
  };

  services.fireqos = {
    enable = true;

    # Debug with
    # fireqos status world-in
    # fireqos status world-out

    # TODO netdata integration not working https://www.netdata.cloud/blog/netdata-qos-monitoring

    # TODO test steam since it's behind nat in a vm
    config = ''
      interface ${externalInterface} world-in input rate ${toString download}mbit
        ###### high - prio 1 ######

        class icmp prio 1
          match mark ${tags.icmp}

        class dns prio 1
          match mark ${tags.dns}

        class wireguard commit 1mbit prio 1
          match mark ${tags.wireguard}

        class wifi_calling prio 1
          match mark ${tags.wifi-calling}

        ###### medium - prio 2 ######

        class default prio 2
          match all

        class private_vlan prio 2
          match mark ${tags.private-vlan}

        class dmz_vlan prio 2
          match mark ${tags.dmz-vlan}

        class iot_vlan prio 2
          match mark ${tags.iot-vlan}

        class guest_vlan prio 2
          match mark ${tags.guest-vlan}

        ###### low - prio 3 ######

        class steam prio 3
          match mark ${tags.steam}

        class torrent prio 3
          match mark ${tags.steam}

        class resilio prio 3
          match mark ${tags.resilio}

        class plex prio 3
          match mark ${tags.plex}

      interface ${externalInterface} world-out output rate ${toString upload}mbit
        ###### high - prio 1 ######

        class icmp prio 1
          match mark ${tags.icmp}

        class dns prio 1
          match mark ${tags.dns}

        class wireguard commit 1mbit prio 1
          match mark ${tags.wireguard}

        class wifi_calling prio 1
          match mark ${tags.wifi-calling}

        ###### medium - prio 2 ######

        class default prio 2
          match all

        class private_vlan prio 2
          match mark ${tags.private-vlan}

        class dmz_vlan prio 2
          match mark ${tags.dmz-vlan}

        class iot_vlan prio 2
          match mark ${tags.iot-vlan}

        class guest_vlan prio 2
          match mark ${tags.guest-vlan}

        ###### low - prio 3 ######

        class steam prio 3
          match mark ${tags.steam}

        class torrent prio 3
          match mark ${tags.steam}

        class resilio prio 3
          match mark ${tags.resilio}

        class plex prio 3
          match mark ${tags.plex}
    '';
  };

  systemd.services.fireqos.wantedBy = [ "multi-user.target" ];
}
