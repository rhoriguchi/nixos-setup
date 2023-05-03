{ lib, secrets, ... }:
let vpnInterface = "tun-deluge";
in {
  services = {
    # TODO make sure dns traffic does not get leaked

    # udev.extraRules = ''
    #   ACTION=="add", SUBSYSTEM=="net", ENV{INTERFACE}=="tun-deluge", RUN+="${pkgs.nettools}/bin/route add -net $(ip route | grep ${vpnInterface} | grep -oP "(\d+\.){3}\d+/\d+")"
    # '';

    # udev.extraRules = ''
    #   ACTION=="add", SUBSYSTEM=="net", ENV{INTERFACE}=="tun-deluge", RUN+="${pkgs.iproute2}/bin/ip route add default via 0.0.0.0 dev ${vpnInterface}"
    # '';

    # default_iface=$(ip route | awk '/default/ {print $5}')
    # default_gateway=$(ip route show dev $default_iface | awk '/default via/ {print $3}')
    # echo "Default gateway IP address: $default_gateway"

    # sudo ip route add default via 192.168.1.1 dev tun-deluge
    # sudo ip route add 192.168.1.1 dev tun-deluge

    openvpn.servers.deluge = {
      config = let
        addresses = {
          # Netherlands
          "62.112.9.164" = 51820;
          "190.2.146.180" = 51820;
          "138.199.7.129" = 51820;
        };

        remotes = lib.mapAttrsToList (ip: port: "remote ${ip} ${toString port}") addresses;
      in ''
        auth SHA512
        verb 3

        client
        dev ${vpnInterface}
        proto udp
        persist-tun

        route-nopull

        ${lib.concatStringsSep "\n" remotes}

        server-poll-timeout 20
        remote-random
        resolv-retry infinite
        nobind

        fast-io
        tun-mtu 1500
        tun-mtu-extra 32
        mssfix 1450
        reneg-sec 0

        persist-key
        ca ${../headless/server/sonarr/deluge/ca.pem}

        setenv CLIENT_CERT 0
        remote-cert-tls server
        tls-auth ${../headless/server/sonarr/deluge/server.key} 1
      '';

      authUserPass = {
        username = secrets.protonvpn.username;
        password = secrets.protonvpn.password;
      };
    };
  };
}
