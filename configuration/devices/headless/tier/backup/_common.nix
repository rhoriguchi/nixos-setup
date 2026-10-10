{ config }:
{
  sources = [
    "/mnt/Data/Movies"
    "/mnt/Data/Series"

    "/var/cache/netdata"
    "/var/lib/${config.services.prometheus.stateDir}"
    "/var/lib/bazarr-anime"
    "/var/lib/bazarr-series-movies"
    "/var/lib/radarr-anime"
    "/var/lib/radarr-movies"
    "/var/lib/sonarr-anime"
    "/var/lib/sonarr-series"

    "/var/lib/private/mealie"
    "/var/lib/private/prowlarr"

    config.services.couchdb.databaseDir
    config.services.home-assistant.configDir
    config.services.jellyfin.dataDir
    config.services.loki.dataDir
    config.services.plex.dataDir
    config.services.syncthing.dataDir
    config.services.tautulli.dataDir
    config.services.tempo.settings.storage.trace.local.path
  ];

  tvtracktimeTables = [
    "api_key"
    "application_user"
    "jwt_token"
    "series_tag"
    "tag"
    "tracked_user_series"
    "user_episode_watch"
    "user_settings"
  ];
}
