{ config, lib, ... }:
let
  containerNames = [
    "tvtracktime-application"
    "tvtracktime-github-runner"
  ];

  existingContainerNames = lib.filter (name: lib.hasAttr name config.containers) containerNames;
  addresses = map (name: config.containers.${name}.localAddress) existingContainerNames;
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
          elements = { ${lib.concatStringsSep ", " addresses} }
        }

        chain input {
          type filter hook input priority filter; policy accept;

          ct state { established, related } accept

          ip saddr @containerAddresses meta l4proto { tcp, udp } th dport { 53 } accept # DNS
          ip saddr @containerAddresses tcp dport 56710 accept # Alloy OTLP receiver

          ip saddr @containerAddresses drop
        }

        chain forward {
          type filter hook forward priority filter; policy accept;

          ip saddr @containerAddresses meta l4proto { tcp, udp } th dport { 53 } accept # DNS

          ip saddr @containerAddresses ip daddr @rfc1918 drop
        }
      '';
    };
  };
}
