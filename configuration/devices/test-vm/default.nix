{ config, pkgs, lib, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [ ./hardware-configuration.nix ];

  users.users.xxlpitu.password = lib.mkForce "asdf1234";

  # duckdns = {
  #   enable = true;
  #   subdomain = "xxlpitu-rain-town";
  # };

  glances.enable = true;

  mal_export = {
    enable = true;
    exportPath = "${syncDir}/mal_export";
  };

  tv_time_export = {
    enable = true;
    exportPath = "${syncDir}/tv_time_export";
  };

  # rslsync = {
  #   enable = false;
  #   syncPath = "${syncDir}";
  # };
}
