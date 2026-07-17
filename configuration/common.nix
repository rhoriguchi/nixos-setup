{
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkOverride 1250 pkgs.linuxPackages_latest;

    # Enable root user in rescue shell
    kernelParams = [ "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
  };

  users = {
    mutableUsers = false;

    users.root.hashedPassword = "*";
  };

  documentation.enable = false;
}
