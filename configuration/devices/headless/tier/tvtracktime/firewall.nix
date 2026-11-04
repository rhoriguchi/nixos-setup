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

        set containerInterfaces {
          type ifname;
          flags interval;
          elements = { ${
            lib.pipe containerNames [
              (map (
                name:
                let
                  full = "ve-${name}";
                in
                if lib.stringLength full > 15 then "${lib.substring 0 11 full}*" else full
              ))

              lib.unique

              (map (interface: ''"${interface}"''))

              (lib.concatStringsSep ", ")
            ]
          } }
        }

        chain input {
          type filter hook input priority filter; policy accept;

          iifname @containerInterfaces jump containers-input-filter
        }

        chain containers-input-filter {
          meta nfproto ipv4 jump containers-input-ipv4-filter

          meta nfproto ipv6 drop
        }

        chain containers-input-ipv4-filter {
          ct state { established, related } accept

          meta l4proto { tcp, udp } th dport { 53 } accept # DNS
          tcp dport 56710 accept # Alloy OTLP receiver
          tcp dport ${toString config.services.custom-netdata.streamPort} accept # Netdata

          # Renderer (container) -> hostAddress:80
          #   -> DNAT to 127.0.0.1 (modules/profiles/containers/networking.nix)
          #   -> host nginx (proxy.nix)
          #   -> application container (frontend, backend, previews, s3)
          ip saddr ${config.containers.tvtracktime-application.localAddress} tcp dport 80 accept

          drop
        }

        chain forward {
          type filter hook forward priority filter; policy accept;

          iifname @containerInterfaces jump containers-forward-filter
        }

        chain containers-forward-filter {
          meta nfproto ipv6 drop

          ip daddr 169.254.0.0/16 drop # nspawn containers
          ip daddr 100.64.0.0/10 drop # Tailnet

          ip daddr @rfc1918 drop
        }
      '';
    };
  };
}
