{ pkgs, ... }: {
  xdg.configFile."spotify/Users/r.horiguchi-user/prefs".text = ''
    audio.crossfade_v2=true
    audio.crossfade.time_v2=${toString (6 * 1000)}
    audio.play_bitrate_non_metered_migrated=true
    ui.track_notifications_enabled=false
  '';

  programs.spicetify = {
    enable = true;

    enabledExtensions =
      [ pkgs.spicetify.extensions.groupSession pkgs.spicetify.extensions.songStats pkgs.spicetify.extensions.volumePercentage ];
  };
}
