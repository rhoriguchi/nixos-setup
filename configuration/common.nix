{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Enable root user in rescue shell
    kernelParams = [ "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
  };

  time.timeZone = "Europe/Zurich";

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

  users = {
    mutableUsers = false;

    users.root.hashedPassword = "*";
  };
}
