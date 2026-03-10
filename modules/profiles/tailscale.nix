{
  config,
  pkgs,
  secrets,
  ...
}:
{
  services.tailscale = {
    enable = true;

    openFirewall = true;

    useRoutingFeatures = "client";
    disableUpstreamLogging = true;

    authKeyFile =
      pkgs.writeText "authKeyFile"
        secrets.headscale.preAuthKeys.${config.networking.hostName}.key;

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
