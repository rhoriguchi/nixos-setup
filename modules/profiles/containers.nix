{
  config,
  lib,
  pkgs,
  ...
}:
let
  interface = "ve-${if config.networking.nftables.enable then "*" else "+"}";
in
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config = {
          extraFlags = [ "--resolv-conf=off" ];

          config = {
            nixpkgs.pkgs = pkgs;

            system.stateVersion = config.system.stateVersion;

            networking = {
              useHostResolvConf = false;
              nameservers = lib.mkDefault [
                "1.1.1.1"
                "1.0.0.1"
              ];
            };
          };
        };
      }
    );
  };

  config = lib.mkIf (lib.any (value: value.privateNetwork) (lib.attrValues config.containers)) {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.route_localnet" = 1;
      "net.ipv4.conf.default.route_localnet" = 1;
    };

    networking = {
      firewall.trustedInterfaces = [
        interface
      ];

      nat = {
        enable = lib.mkDefault true;

        internalInterfaces = [ interface ];
      };

      nftables.tables.nspawn = lib.mkIf config.networking.nftables.enable {
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
  };
}
