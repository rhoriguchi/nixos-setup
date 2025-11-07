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
        secrets.headscale.preAuthKeys.${config.networking.hostName};

    extraSetFlags = [
      "--accept-dns=false"
      "--update-check=false"
    ];

    extraUpFlags = [
      "--force-reauth"
      "--login-server=https://headscale.00a.ch"
      "--reset"
    ];
  };
}
