{ osConfig, ... }:
{
  services.tailscale-systray.enable = osConfig.services.tailscale.enable;
}
