{
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

  users = {
    mutableUsers = false;

    users.root.hashedPassword = "*";
  };
}
