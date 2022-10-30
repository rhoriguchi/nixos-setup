{ lib, config, ... }:
let
  cfg = config.services.wireguard-vpn;

  ips = import ./ips.nix;
  clientIps = lib.filterAttrs (key: _: key != "server") ips;

  keys = import ./secrets.nix;
  clientKeys = lib.filterAttrs (key: _: key != "server") keys;

  serverAddress = "wireguard.00a.ch";
  serverPort = 51820;

  isClient = cfg.type == "client";
  isServer = cfg.type == "server";
in {
  options.services.wireguard-vpn = {
    enable = lib.mkEnableOption "Private VPN";
    type = lib.mkOption { type = lib.types.nullOr (lib.types.enum [ "client" "server" ]); };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = isServer -> config.services.infomaniak.enable;
        message = "When type is server infomaniak service must be enabled";
      }
      {
        assertion = isClient -> lib.elem config.networking.hostName (lib.attrNames clientKeys);
        message = "When type is client key needs to exist for hostname";
      }
      {
        assertion = isClient -> lib.elem config.networking.hostName (lib.attrNames clientIps);
        message = "When type is client ip needs to exist for hostname";
      }
    ];

    networking.wireguard.interfaces = {
      wg0 = {
        server = {
          listenPort = serverPort;

          ips = [ "${ips.server}/24" ];
          privateKey = keys.server.private;

          peers = lib.attrValues (lib.mapAttrs (key: value: {
            publicKey = value.public;
            allowedIPs = [ "${clientIps.${key}}/32" ];
          }) clientKeys);
        };

        client = {
          ips = [ "${clientIps.${config.networking.hostName}}/24" ];
          privateKey = clientKeys.${config.networking.hostName}.private;

          peers = [{
            publicKey = keys.server.public;
            allowedIPs = [ "${ips.server}/32" ];
            endpoint = "${serverAddress}:${toString serverPort}";

            persistentKeepalive = 25;
            dynamicEndpointRefreshSeconds = 30;
          }];
        };
      }.${cfg.type};
    };

    services.infomaniak.hostnames = lib.mkIf isServer [ serverAddress ];

    networking.firewall.allowedUDPPorts = lib.mkIf isServer [ serverPort ];
  };
}
