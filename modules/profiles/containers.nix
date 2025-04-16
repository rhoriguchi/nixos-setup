{ config, lib, ... }: {
  networking.nat = {
    enable = lib.mkDefault (builtins.any (value: value.privateNetwork) (lib.attrValues config.containers));

    internalInterfaces = [ "ve-${if config.networking.nftables.enable then "*" else "+"}" ];
  };
}
