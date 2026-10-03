{ config, lib, ... }:
let
  containerNames = [
    "tvtracktime-application"
    "tvtracktime-github-runner"
  ];
in
{
  assertions = map (name: {
    assertion = lib.hasAttr name config.containers;
    message = "configuration/devices/headless/tier/tvtracktime/firewall.nix expects container '${name}' to exist in config.containers";
  }) containerNames;

  networking.nftables = {
    enable = true;

    tables.tvtracktime = {
      family = "inet";

      content = ''
        set rfc1918 {
          type ipv4_addr;
          flags interval;
          elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 }
        }

        set containerAddresses {
          type ipv4_addr;
          elements = { ${
            lib.pipe containerNames [
              (lib.filter (name: lib.hasAttr name config.containers))
              (map (name: config.containers.${name}.localAddress))
              (lib.concatStringsSep ", ")
            ]
          } }
        }

        chain input {
          type filter hook input priority filter; policy accept;

          ct state { established, related } accept

          ip saddr @containerAddresses jump containers-input-filter
        }

        chain containers-input-filter {
          meta l4proto { tcp, udp } th dport { 53 } accept # DNS
          tcp dport 56710 accept # Alloy OTLP receiver
          tcp dport ${toString config.services.custom-netdata.streamPort} accept # Netdata

          drop
        }

        chain forward {
          type filter hook forward priority filter; policy accept;

          ip saddr @containerAddresses jump containers-forward-filter
        }

        chain containers-forward-filter {
          meta l4proto { tcp, udp } th dport { 53 } accept # DNS

          ip daddr 169.254.1.0/24 drop
          ip daddr @rfc1918 drop
        }
      '';
    };
  };
}
