{ config, lib, ... }:
{
  networking.nat = {
    enable = lib.mkDefault (lib.any (value: value.privateNetwork) (lib.attrValues config.containers));

    internalInterfaces = [ "ve-${if config.networking.nftables.enable then "*" else "+"}" ];
  };
}
