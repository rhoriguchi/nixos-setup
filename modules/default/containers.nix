{ config, lib, ... }:
let
  interface = "ve-${if config.networking.nftables.enable then "*" else "+"}";

  hostAddresses = lib.unique (
    lib.mapAttrsToList (_: value: value.hostAddress) (
      lib.filterAttrs (_: value: value.hostAddress != null) config.containers
    )
  );
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

    nftables.tables.nspawn = lib.mkIf (config.networking.nftables.enable && hostAddresses != [ ]) {
      family = "ip";

      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;

          ${lib.concatMapStringsSep "\n" (addr: ''
            iifname "${interface}" ip daddr ${addr} dnat to 127.0.0.1
          '') hostAddresses}
        }
      '';
    };
  };
}
