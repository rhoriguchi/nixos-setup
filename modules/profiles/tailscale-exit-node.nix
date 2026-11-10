{ lib, ... }:
let
  commonFlags = [
    "--advertise-exit-node"
    "--exit-node-allow-lan-access=false"
  ];
in
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = lib.mkDefault 1;
    "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
  };

  services.tailscale = {
    extraSetFlags = commonFlags;
    extraUpFlags = commonFlags;
  };
}
