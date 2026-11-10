{ config, lib, ... }: {
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
      dates = "05:00";

      ensureFree = "500G";
      keepRecent = lib.mkForce "${toString (6 * 30)}d";
      deleteOlderThan = lib.mkForce null;
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    5000
  ];
}
