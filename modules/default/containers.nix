{ config, lib, ... }:
let
  interface = "ve-${if config.networking.nftables.enable then "*" else "+"}";
in
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.route_localnet" = 1;
    "net.ipv4.conf.default.route_localnet" = 1;
  };

  networking = {
    firewall.trustedInterfaces = [
      interface
    ];

    nat = {
      enable = lib.mkDefault (lib.any (value: value.privateNetwork) (lib.attrValues config.containers));

      internalInterfaces = [ interface ];
    };

    nftables.tables.nspawn = lib.mkIf (config.networking.nftables.enable && config.containers != { }) {
      family = "ip";

      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;

          ${lib.pipe config.containers [
            (lib.filterAttrs (_: value: value.hostAddress != null))

            (lib.mapAttrsToList (_: value: value.hostAddress))

            lib.unique

            (map (addr: ''iifname "${interface}" ip daddr ${addr} dnat to 127.0.0.1''))

            (lib.concatStringsSep "\n")
          ]}
        }
      '';
    };
  };
}
