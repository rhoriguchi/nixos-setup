{ libCustom, ... }:
let
  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  nix.settings = {
    substituters = [ "http://${tailscaleIps.XXLPitu-Tier.ip}:5000" ];
    trusted-public-keys = [ "nix-cache-1:jpkey3dBIx4vsr3TEUmNB1iljoJcrD5aEnfYrWcuX+k=" ];
  };
}
