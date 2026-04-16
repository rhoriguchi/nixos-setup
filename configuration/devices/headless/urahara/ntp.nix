{
  config,
  lib,
  interfaces,
  ...
}:
let
  internalInterface = interfaces.internal;
  internalInterfaces = lib.filter (interface: lib.hasPrefix internalInterface interface) (
    lib.attrNames config.networking.interfaces
  );
in
{
  networking.firewall.interfaces = lib.listToAttrs (
    map (
      interfaceName:
      lib.nameValuePair interfaceName {
        allowedUDPPorts = [
          123 # NTP
        ];
      }
    ) internalInterfaces
  );

  services.chrony = {
    enable = true;

    extraConfig = ''
      allow 10.0.0.0/8
      allow 172.16.0.0/12
      allow 192.168.0.0/16
    '';
  };
}
