{ config, lib, ... }:
let
  cfg = config.services.networkTopology;

  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  options.services.networkTopology = {
    enable = lib.mkEnableOption "Build a network topology map with NetVisor";
    serverHostname = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    apiKey = lib.mkOption { type = lib.types.str; };

    networkId = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "92e3eb07-8cd7-4c8b-bfa4-3e67c109eebd";
    };

    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "tailscale service must be enabled";
      }
    ];

    services.netvisor.daemon = {
      enable = true;

      name = config.networking.hostName;
      mode = "pull";

      serverUrl =
        if cfg.isServer then
          "http://127.0.0.1:${toString config.services.netvisor.server.port}"
        else
          "http://${tailscaleIps.${cfg.serverHostname}}:60072";
      daemonApiKey = if cfg.isServer then null else cfg.apiKey;
      inherit (cfg) networkId;
    };
  };
}
