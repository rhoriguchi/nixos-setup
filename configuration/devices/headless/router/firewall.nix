{ interfaces, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  serverIp = "192.168.2.2";
in {
  networking.nat = {
    enable = true;

    externalInterface = externalInterface;
    internalInterfaces =
      [ "${internalInterface}" "${internalInterface}.1" "${internalInterface}.2" "${internalInterface}.3" "${internalInterface}.100" ];

    forwardPorts = [
      {
        proto = "tcp";
        destination = serverIp;
        sourcePort = 25565; # Minecraft
      }
      {
        proto = "tcp";
        destination = serverIp;
        sourcePort = 32400; # Plex
      }
    ];
  };
}
