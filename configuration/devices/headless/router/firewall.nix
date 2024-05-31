{ interfaces, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  serverIp = "192.168.2.2";
in {
  networking = {
    nftables.enable = true;

    nat = {
      enable = true;

      externalInterface = externalInterface;
      internalInterfaces =
        [ "${internalInterface}" "${internalInterface}.1" "${internalInterface}.2" "${internalInterface}.3" "${internalInterface}.100" ];

      forwardPorts = [
        # Minecraft
        {
          proto = "tcp";
          destination = "${serverIp}:25565";
          sourcePort = 25565;
        }

        # Plex
        {
          proto = "tcp";
          destination = "${serverIp}:32400";
          sourcePort = 32400;
        }
      ];
    };
  };
}
