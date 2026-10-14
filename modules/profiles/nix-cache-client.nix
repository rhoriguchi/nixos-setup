{ libCustom, ... }:
let
  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  nix.settings = {
    substituters = [ "http://${tailscaleIps.XXLPitu-Tier.ip}:5000" ];
    trusted-public-keys = [ "nix-cache-1:aLOypntWVuLKNiKhAafGKbT6ueKqvb1DCeu6ywSP408=" ];
  };
}
