{ config, ... }:
{
  sops.secrets."tailscale+services/headscale/preAuthKeys/${config.networking.hostName}" = {
    key = "services/headscale/preAuthKeys/${config.networking.hostName}";

    restartUnits = [ config.systemd.services.tailscaled-autoconnect.name ];
  };

  services.tailscale = {
    enable = true;

    openFirewall = true;

    useRoutingFeatures = "client";
    disableUpstreamLogging = true;

    authKeyFile =
      config.sops.secrets."tailscale+services/headscale/preAuthKeys/${config.networking.hostName}".path;

    extraSetFlags = [
      "--update-check=false"
    ];

    extraUpFlags = [
      "--accept-dns=false"
      "--accept-routes=false"
      "--login-server=https://headscale.00a.ch"
      "--ssh=false"

      "--force-reauth"
    ];
  };
}
