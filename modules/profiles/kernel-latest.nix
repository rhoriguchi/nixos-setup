{ lib, pkgs, ... }:
{
  boot.kernelPackages = lib.mkOverride 1250 pkgs.linuxPackages_latest;
}
