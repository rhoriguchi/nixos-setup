{ pkgs, lib, ... }:
with lib;
let
  dataDir = "/tmp";
  syncDir = "${dataDir}/Sync";
in {
  imports = [ ../default.nix ./hardware-configuration.nix ];

  networking.hostName = "TEST-SERVER-VM";

  environment.systemPackages = with pkgs.linuxPackages;
    [ virtualboxGuestAdditions ];

  users.users.xxlpitu.password = mkForce "asdf1234";

  services = {
    duckdns = {
      enable = true;
      subdomain = "xxlpitu-rain-town";
    };

    mal_export = {
      enable = true;
      exportPath = "${syncDir}/mal_export";
    };

    tv_time_export = {
      enable = true;
      exportPath = "${syncDir}/tv_time_export";
    };

    rslsync = {
      enable = false;
      checkForUpdates = false;
      syncPath = "${syncDir}";
    };

    log2ram.enable = true;
  };

  systemd.services = {
    duckdns.enable = false;
    rslsync.enable = false;
  };
}
