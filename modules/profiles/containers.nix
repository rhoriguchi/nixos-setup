{ config, lib, ... }:
let
  interface = "ve-${if config.networking.nftables.enable then "*" else "+"}";
in
{
  networking = {
    firewall.trustedInterfaces = [
      interface
    ];

    nat = {
      enable = lib.mkDefault (lib.any (value: value.privateNetwork) (lib.attrValues config.containers));

      internalInterfaces = [ interface ];
    };
  };
}
