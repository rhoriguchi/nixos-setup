{ config, lib, ... }:
let
  keepRecentDays = 6 * 30;
  ensureFreeGiB = 500;
in
{
  sops.secrets."nix/cache/nix-cache-1/signingKey".restartUnits = [
    config.systemd.services.harmonia.name
  ];

  services.harmonia = {
    cache = {
      enable = true;

      signKeyPaths = [ config.sops.secrets."nix/cache/nix-cache-1/signingKey".path ];

      settings.priority = 30; # lower than cache.nixos.org's 40
    };

    gc = {
      enable = true;

      automatic = true;
      ensureFree = "${toString ensureFreeGiB}G";
      keepRecent = "${toString keepRecentDays}d";
      deleteOlderThan = lib.mkForce null;
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    5000
  ];
}
