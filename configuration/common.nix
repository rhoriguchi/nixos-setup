{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Enable root user in rescue shell
    kernelParams = [ "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
  };

  time.timeZone = "Europe/Zurich";

  nixpkgs.config.permittedInsecurePackages =
    [ ]
    # TODO remove when https://github.com/project-chip/connectedhomeip/issues/25688 fixed
    ++ lib.optionals config.services.home-assistant.enable [ "openssl-1.1.1w" ];

  services.wireguard-network = {
    enable = true;

    type = "client";
    serverHostname = "XXLPitu-Router";
  };

  services.tailscale = {
    enable = true;

    # TODo allow traffic in between vlans? services.tailscale.port (41641)
    openFirewall = true;

    authKeyFile = "";
    extraUpFlags = [ "--login-server headscale.00a.ch" ];
    # TODO maybe
    # extraSetFlags = [ "--accept-dns" ];
  };

  users = {
    mutableUsers = false;

    users.root.hashedPassword = "*";
  };
}
