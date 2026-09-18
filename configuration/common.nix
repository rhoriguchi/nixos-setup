{
  lib,
  pkgs,
  ...
}:
{
  boot.kernelPackages = lib.mkOverride 1250 pkgs.linuxPackages_latest;

  users = {
    mutableUsers = false;

    users.root.hashedPassword = "*";
  };

  documentation.enable = false;
}
