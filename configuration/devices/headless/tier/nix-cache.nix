{ config, pkgs, ... }:
let
  cacheMaxSizeGiB = 750;
in
{
  sops.secrets."nix/cache/nix-cache-1/signingKey".restartUnits = [
    config.systemd.services.harmonia.name
  ];

  services.harmonia.cache = {
    enable = true;

    signKeyPaths = [ config.sops.secrets."nix/cache/nix-cache-1/signingKey".path ];

    settings.priority = 30; # lower than cache.nixos.org's 40
  };

  # Harmonia serves Tier's own live /nix/store. Reachability GC only
  # protects what Tier itself still needs, not content other hosts want -
  # so root each day's closure explicitly, pruned oldest-first by size.
  systemd.services.nix-cache-prune = {
    script = ''
      root=/nix/var/nix/gcroots/nix-cache-prune
      mkdir -p "$root"
      ln -sfn "$(readlink /run/current-system)" "$root/$(date +%Y-%m-%d)"

      budget_kib=${toString (cacheMaxSizeGiB * 1024 * 1024)}

      while [ "$(du -sk /nix/store | cut -f1)" -gt "$budget_kib" ]; do
        [ "$(${pkgs.findutils}/bin/find "$root" -maxdepth 1 -mindepth 1 | wc -l)" -le 1 ] && break # never drop the last root

        oldest=$(${pkgs.findutils}/bin/find "$root" -maxdepth 1 -mindepth 1 -printf '%T@ %p\n' | sort -n | head -n1 | cut -d' ' -f2-)
        rm -f "$oldest"
        ${config.nix.package}/bin/nix store gc
      done

      ${config.nix.package}/bin/nix store gc
    '';

    serviceConfig.Type = "oneshot";

    startAt = "04:00";
  };

  systemd.timers.nix-cache-prune.timerConfig.Persistent = true;

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    5000
  ];
}
