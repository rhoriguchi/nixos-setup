{ lib, config, pkgs, secrets, ... }:
let
  synologyIp = "192.168.1.51";
  synologyCredentialsFile = pkgs.writeText "smb-secrets" ''
    username=${secrets.synology.username}
    password=${secrets.synology.password}
  '';

  wdMyCloudIp = "192.168.1.55";
  wdMyCloudCredentialsFile = pkgs.writeText "smb-secrets" ''
    username=${secrets.wdMycloud.username}
    password=${secrets.wdMycloud.password}
  '';

  getExtraOptions = credentialsFile:
    let
      options = [
        "credentials=${credentialsFile}"
        "noauto"
        "x-systemd.automount"
        "x-systemd.device-timeout=5s"
        "x-systemd.idle-timeout=60"
        "x-systemd.mount-timeout=5s"
      ] ++ lib.optionals config.services.plex.enable [ "gid=plex" "uid=plex" ];
    in lib.concatStringsSep "," options;
in {
  system.activationScripts.rhoriguchiSetup = ''
    mkdir -p /mnt/Media/Videos
  '';

  fileSystems = {
    "/mnt/Media/Videos/Movies" = {
      device = "//${synologyIp}/JcrK - Shared Media/Videos/Movies";
      fsType = "cifs";
      options = [ "${getExtraOptions synologyCredentialsFile}" ];
    };

    "/mnt/Media/Videos/TV Shows" = {
      device = "//${wdMyCloudIp}/Data/Media/TV Shows";
      fsType = "cifs";
      options = [ "${getExtraOptions wdMyCloudCredentialsFile}" ];
    };

    "/mnt/Music" = {
      device = "//${synologyIp}/JcrK - James/Music/iTunes/iTunes Media/Music";
      fsType = "cifs";
      options = [ "${getExtraOptions synologyCredentialsFile}" ];
    };
  };
}
