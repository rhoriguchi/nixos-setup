{ lib, pkgs, ... }:
let
  audio-converter = pkgs.python3Packages.buildPythonApplication {
    pname = "audio-converter";
    version = "1";

    src = ./src;

    propagatedBuildInputs = [ pkgs.mediainfo pkgs.ffmpeg ];
  };

  getService = paths: startAt: {
    after = [ "network.target" ];
    description = "audio-converter";
    serviceConfig = {
      ExecStart = lib.concatStringsSep " && " (map (path: ''${audio-converter}/bin/audio-converter "${path}" eac3 ac3'') paths);
      Restart = "on-abort";
      User = "plex";
      Group = "plex";
    };
    inherit startAt;
  };
in {
  systemd.services = {
    audio-converter-daily =
      getService [ "/mnt/Media/Videos/_Downloads to Install" "/mnt/Media/Videos/TV Shows" ] "Mon,Wed,Thu,Fri,Sat,Sun 15:00:00";
    audio-converter-weekly = getService [ "/mnt/Media" ] "Tue 15:00:00";
  };
}