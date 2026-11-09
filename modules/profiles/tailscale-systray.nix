{ config, lib, ... }:
let
  operators = lib.attrNames (
    lib.filterAttrs (_: user: user.isNormalUser && lib.elem "wheel" user.extraGroups) config.users.users
  );
in
{
  assertions = [
    {
      assertion = lib.length operators <= 1;
      message = "Tailscale supports a single operator, found: ${lib.concatStringsSep ", " operators}";
    }
  ];

  services.tailscale.extraSetFlags = lib.map (name: "--operator=${name}") operators;
}
