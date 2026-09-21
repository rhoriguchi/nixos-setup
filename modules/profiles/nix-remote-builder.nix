{ config, libCustom, ... }:
let
  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  sops.secrets."nix/buildMachines/${config.networking.hostName}/privateKey" = { };

  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
        hostName = tailscaleIps.XXLPitu-Tier.ip;

        protocol = "ssh-ng";

        sshUser = "nix-ssh";
        sshKey = config.sops.secrets."nix/buildMachines/${config.networking.hostName}/privateKey".path;
        # > ssh xxlpitu-tier "base64 -w0 /etc/ssh/ssh_host_ed25519_key.pub"
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSURFSVZnd0gwd2pqUWI3ZWtWeFl0RXlISGpnVi9Rd3MwSzlKN2xYU1hlWVcgcm9vdEBuaXhvcwo=";

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        maxJobs = 24;
        speedFactor = 2;

        supportedFeatures = [ "big-parallel" ];
      }
    ];

    settings.builders-use-substitutes = true;
  };
}
