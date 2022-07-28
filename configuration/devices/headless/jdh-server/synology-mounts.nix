{ lib, config, pkgs, secrets, ... }:
let
  credentialsFile = pkgs.writeText "smb-secrets" ''
    username=${secrets.synology.username}
    password=${secrets.synology.password}
  '';

  extraOptions = let
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
  fileSystems = {
    "/mnt/Media" = {
      device = "//192.168.1.51/JcrK - Shared Media";
      fsType = "cifs";
      options = [ "${extraOptions}" ];
    };

    "/mnt/Music" = {
      device = "//192.168.1.51/JcrK - James/Music/iTunes/iTunes Media/Music";
      fsType = "cifs";
      options = [ "${extraOptions}" ];
    };
  };
}
