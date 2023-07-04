{ lib, config, pkgs, secrets, ... }:
let
  synologyMediaIp = "192.168.1.51";
  synologyBackupIp = "192.168.1.52";

  synologyCredentialsFile = pkgs.writeText "smb-secrets" ''
    username=${secrets.synology.username}
    password=${secrets.synology.password}
  '';

  wdMyCloudIp = "192.168.1.55";
  wdMyCloudCredentialsFile = pkgs.writeText "smb-secrets" ''
    username=${secrets.wdMycloud.username}
    password=${secrets.wdMycloud.password}
  '';

  getExtraOptions = credentialsFile: plexOwner:
    let
      options = [
        "credentials=${credentialsFile}"
        "noauto"
        "x-systemd.after=network-online.target"
        "x-systemd.automount"
        "x-systemd.device-timeout=5s"
        "x-systemd.idle-timeout=60"
        "x-systemd.mount-timeout=5s"
      ] ++ lib.optionals plexOwner [ "gid=plex" "uid=plex" ];
    in lib.concatStringsSep "," options;
in {
  system.activationScripts.rhoriguchiSetup = ''
    mkdir -p /mnt/Media/Videos

    chown plex:plex "/mnt/Media/Videos/Movies"
    chown plex:plex "/mnt/Media/Videos/TV Shows WD"
    chown plex:plex "/mnt/Media/Videos/TV Shows"
    chown plex:plex "/mnt/Music"
  '';

  fileSystems = {
    "/mnt/Media/Videos/Movies" = {
      device = "//${synologyMediaIp}/JcrK - Shared Media/Videos/Movies";
      fsType = "cifs";
      options = [ "${getExtraOptions synologyCredentialsFile config.services.plex.enable}" ];
    };

    "/mnt/Media/Videos/TV Shows WD" = {
      device = "//${wdMyCloudIp}/Data/Media/TV Shows";
      fsType = "cifs";
      options = [ "${getExtraOptions wdMyCloudCredentialsFile config.services.plex.enable}" ];
    };

    "/mnt/Media/Videos/TV Shows" = {
      device = "//${synologyBackupIp}/JcrK - Shared Media 2/TV Shows";
      fsType = "cifs";
      options = [ "${getExtraOptions synologyCredentialsFile config.services.plex.enable}" ];
    };

    "/mnt/Music" = {
      device = "//${synologyMediaIp}/JcrK - James/Music/iTunes/iTunes Media/Music";
      fsType = "cifs";
      options = [ "${getExtraOptions synologyCredentialsFile config.services.plex.enable}" ];
    };

    "/mnt/WD_Backup" = {
      device = "//${wdMyCloudIp}/Backup";
      fsType = "cifs";
      options = [ "${getExtraOptions wdMyCloudCredentialsFile false}" ];
    };
  };
}
