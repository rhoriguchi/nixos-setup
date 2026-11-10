{ config, ... }:
let
  commonFlags = [
    "--accept-dns=false"
    "--accept-routes=false"
    "--ssh=false"
  ];
in
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

    extraSetFlags = commonFlags ++ [
      "--update-check=false"
    ];

    extraUpFlags = commonFlags ++ [
      "--login-server=https://headscale.00a.ch"
      "--force-reauth"
    ];
  };
}
