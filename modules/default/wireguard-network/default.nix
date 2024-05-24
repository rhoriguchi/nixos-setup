{ lib, config, ... }:
let
  cfg = config.services.wireguard-network;

  ips = import ./ips.nix;
  keys = import ./secrets.nix;

  serverAddress = "wireguard.00a.ch";
  serverPort = 51820;

  isServer = cfg.type == "server";
  isClient = cfg.type == "client";
in {
  options.services.wireguard-network = {
    enable = lib.mkEnableOption "Private VPN";
    type = lib.mkOption { type = lib.types.nullOr (lib.types.enum [ "client" "server" ]); };
    serverHostname = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "wg-management";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = isServer -> config.services.infomaniak.enable;
        message = "When type is server infomaniak service must be enabled";
      }
      {
        assertion = isClient -> lib.elem config.networking.hostName (lib.attrNames keys);
        message = "When type is client key needs to exist for hostname";
      }
      {
        assertion = isClient -> lib.elem config.networking.hostName (lib.attrNames ips);
        message = "When type is client ip needs to exist for hostname";
      }
      {
        assertion = isClient -> cfg.serverHostname != null;
        message = "When type is client serverHostname must be set";
      }
      {
        assertion = isClient -> builtins.elem cfg.serverHostname (lib.attrNames ips);
        message = "When type is client ip needs to exist for serverHostname";
      }
      {
        assertion = isClient -> builtins.elem cfg.serverHostname (lib.attrNames keys);
        message = "When type is client key needs to exist for serverHostname";
      }
    ];

    boot.kernel.sysctl = lib.optionalAttrs isServer { "net.ipv4.ip_forward" = 1; };

    networking = {
      firewall.allowedUDPPorts = lib.mkIf isServer [ serverPort ];

      wireguard.interfaces = {
        "${cfg.interfaceName}" = {
          server = {
            listenPort = serverPort;

            ips = [ "${ips.${config.networking.hostName}}/24" ];
            privateKey = keys.${config.networking.hostName}.private;

            peers = let
              clientIps = lib.filterAttrs (key: _: key != config.networking.hostName) ips;
              clientKeys = lib.filterAttrs (key: _: key != config.networking.hostName) keys;
            in lib.attrValues (lib.mapAttrs (key: value: {
              publicKey = value.public;
              allowedIPs = [ "${clientIps.${key}}/32" ];
            }) clientKeys);
          };

          client = {
            ips = [ "${ips.${config.networking.hostName}}/32" ];
            privateKey = keys.${config.networking.hostName}.private;

            peers = [{
              publicKey = keys.${cfg.serverHostname}.public;
              allowedIPs = [ "10.123.123.0/24" ];
              endpoint = "${serverAddress}:${toString serverPort}";

              persistentKeepalive = 25;
              dynamicEndpointRefreshSeconds = 30;
            }];
          };
        }.${cfg.type};
      };
    };

    services.infomaniak.hostnames = lib.mkIf isServer [ serverAddress ];
  };
}
