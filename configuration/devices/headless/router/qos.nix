{ config, interfaces, ... }:
let
  externalInterface = interfaces.external;

  download = 65;
  upload = 24;
in {
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

        class ping prio 1
          match icmp

        class dns prio 1
          match tcp port 53
          match udp port 53

        class wireguard commit 1mbit prio 1
          match udp port 51820

        class wifi_calling prio 1
          match udp port 500
          match udp port 4500

        ###### medium - prio 2 ######

        class default prio 2
          match all

        class private_vlan prio 2
          match src 192.168.1.0/24

        class dmz_vlan prio 2
          match src 192.168.2.0/24

        class iot_vlan prio 2
          match src 192.168.3.0/24

        class guest_vlan prio 2
          match src 192.168.100.0/24

        ###### low - prio 3 ######

        class steam prio 3
          match dport 27015:27050

        class torrent prio 3
          match tcp port 6881:6999

        class resilio prio 3
          match tcp port 5555

        class plex prio 3
          match tcp port 32400

      interface ${externalInterface} world-out output rate ${toString upload}mbit
        ###### high - prio 1 ######

        class ping prio 1
          match icmp

        class dns prio 1
          match tcp port 53
          match udp port 53

        class wireguard commit 1mbit prio 1
          match udp port 51820

        class wifi_calling prio 1
          match udp port 500
          match udp port 4500

        ###### medium - prio 2 ######

        class default prio 2
          match all

        class private_vlan prio 2
          match dst 192.168.1.0/24

        class dmz_vlan prio 2
          match dst 192.168.2.0/24

        class iot_vlan prio 2
          match dst 192.168.3.0/24

        class guest_vlan prio 2
          match dst 192.168.100.0/24

        ###### low - prio 3 ######

        class steam prio 3
          match dport 27015:27050

        class torrent prio 3
          match tcp port 6881:6999

        class resilio prio 3
          match tcp port 5555

        class plex prio 3
          match tcp port 32400
    '';
  };

  systemd.services.fireqos.wantedBy = [ "multi-user.target" ];
}
