import requests


class TVTrackTimeRequestHandler(object):
    def __init__(self, api_url, api_key):
        self._base_url = api_url.rstrip("/")
        self._session = self._get_session()
        self._api_key = api_key

        self._login()

    @staticmethod
    def _get_session():
        session = requests.session()
        return session

    def _login(self):
        response = self._session.post(
            f"{self._base_url}/auth/login/api-key",
            json={"apiKey": self._api_key},
        )

        if not response.ok:
            raise ValueError(
                f"TvTrackTime returned status code {response.status_code} with reason: {response.reason}"
            )

        token = response.json()["token"]

        self._session.headers.update({"Authorization": f"Bearer {token}"})

    def get_in_progress_tvdb_ids(self):
        response = self._session.get(f"{self._base_url}/user/series")
        if not response.ok:
            raise ValueError(
                f"TvTrackTime returned status code {response.status_code} with reason: {response.reason}"
            )

        series_list = response.json()
        tvdb_ids = [
            series["seriesId"]
            for series in series_list
            if series.get("state") in ("IN_PROGRESS", "NEWLY_AIRED") and not series.get("archived")
        ]

        return tvdb_ids

    def get_unwatched_episodes(self, tvdb_id):
        response = self._session.get(f"{self._base_url}/user/series/{tvdb_id}")
        if not response.ok:
            raise ValueError(
                f"TvTrackTime returned status code {response.status_code} for series {tvdb_id}: {response.reason}"
            )

        details = response.json()
        unwatched = {}

        for season in details.get("seasons", []):
            season_number = season["number"]
            unwatched_episodes = []

            for episode in season.get("episodes", []):
                if episode.get("watchCount", 0) == 0:
                    unwatched_episodes.append(episode["number"])

            if unwatched_episodes:
                unwatched[season_number] = unwatched_episodes

        return unwatched


class SonarrHelper(object):
    def __init__(self, host_url, api_key, root_dir):
        self._base_url = f"{host_url}/api/v3"
        self._session = self._get_session(api_key)
        self._root_dir = root_dir

        self._add_root_dir(root_dir)

        self._quality_profile_id = self.get_quality_profile_id("Any")
        self._language_profile_id = self.get_language_profile_id("English")
        self._tag_id = self.get_tag_id("tv_track_time")

    @staticmethod
    def _get_session(api_key):
        session = requests.session()
        session.headers.update({"X-Api-Key": api_key})
        return session

    def _get_all_quality_profiles(self):
        return self._session.get(f"{self._base_url}/qualityprofile").json()

    def get_quality_profile_id(self, name):
        match = next(
            filter(
                lambda profile: profile["name"].lower() == name.lower(),
                self._get_all_quality_profiles(),
            )
        )

        if not match:
            raise ValueError(f'No quality profile found with name "{name}"')

        return match["id"]

    def _get_all_languages(self):
        return self._session.get(f"{self._base_url}/language").json()

    def get_language_profile_id(self, name):
        match = next(
            filter(
                lambda profile: profile["name"].lower() == name.lower(),
                self._get_all_languages(),
            )
        )

        if not match:
            raise ValueError(f'No language profile found with name "{name}"')

        return match["id"]

    def _get_all_series(self):
        return self._session.get(f"{self._base_url}/series").json()

    def _lookup_series(self, tvdb_id):
        series = self._session.get(
            f"{self._base_url}/series/lookup", params={"term": f"tvdb:{tvdb_id}"}
        ).json()

        if len(series) != 1:
            raise ValueError(f'More than one series found with tvdb_id "{tvdb_id}"')

        return series[0]

    def _add_root_dir(self, root_dir):
        self._session.post(f"{self._base_url}/rootFolder", json={"path": root_dir})

    def get_tag_id(self, tag):
        return self._session.post(f"{self._base_url}/tag", json={"label": tag}).json()[
            "id"
        ]

    def _get_series(self, tvdb_id):
        series = self._lookup_series(tvdb_id)

        if "id" not in series:
            raise ValueError(f'Series with tvdb_id "{tvdb_id}" not added')

        return series

    def _add_series(self, series):
        self._session.post(
            f"{self._base_url}/series",
            json=series | {
                "rootFolderPath": self._root_dir,
                "qualityProfileId": self._quality_profile_id,
                "languageProfileId": self._language_profile_id,
                "tags": [self._tag_id],
            },
        )

    def _update_series(self, series):
        if "id" not in series:
            raise ValueError(f'Series with tvdb_id "{series["tvdbId"]}" not added')

        self._session.put(
            f"{self._base_url}/series",
            json=series | {"tags": list(set(series["tags"] + [self._tag_id]))},
        )

    def _delete_tag(self, id):
        series = self._session.get(f"{self._base_url}/series/{id}").json()

        series["tags"] = list(filter(lambda tag: tag != self._tag_id, series["tags"]))

        self._session.put(f"{self._base_url}/series", json=series)

    def _untag_and_unmonitor(self, id):
        series = self._session.get(f"{self._base_url}/series/{id}").json()

        series["tags"] = list(filter(lambda tag: tag != self._tag_id, series["tags"]))
        series["monitored"] = False
        series["seasons"] = list(
            map(lambda season: season | {"monitored": False}, series["seasons"])
        )

        self._session.put(f"{self._base_url}/series", json=series)

        for episode in self._get_episodes(id):
            if episode["monitored"]:
                self._set_episode_monitored(episode["id"], False)

    def _delete_series(self, id):
        self._delete_tag(id)
        self._session.delete(
            f"{self._base_url}/series/{id}", params={"deleteFiles": False}
        )

    def _get_episodes(self, series_id):
        return self._session.get(
            f"{self._base_url}/episode", params={"seriesId": series_id}
        ).json()

    def _has_downloaded_episodes(self, series_id):
        return any(
            episode.get("hasFile") for episode in self._get_episodes(series_id)
        )

    def _set_episode_monitored(self, id, monitored):
        self._session.put(
            f"{self._base_url}/episode/monitor",
            json={"episodeIds": [id], "monitored": monitored},
        )

    def _command_refresh_series(self):
        self._session.post(f"{self._base_url}/command", json={"name": "RefreshSeries"})

    def _command_episode_search(self, episode_id):
        self._session.post(
            f"{self._base_url}/command",
            json={"name": "EpisodeSearch", "episodeIds": [episode_id]},
        )

    def delete_all_missing_series(self, tvdb_ids):
        for series in self._get_all_series():
            if self._tag_id in series["tags"] and series["tvdbId"] not in tvdb_ids:
                if self._has_downloaded_episodes(series["id"]):
                    print(f'Untagging and unmonitoring "{series["title"]}" (episodes downloaded)')
                    self._untag_and_unmonitor(series["id"])
                else:
                    print(f'Removing "{series["title"]}"')
                    self._delete_series(series["id"])

    def add_series(self, tvdb_id):
        series = self._lookup_series(tvdb_id)

        if "id" not in series:
            print(f'Adding "{series["title"]}"')

            self._add_series(series | {"addOptions": {"monitor": "none"}})

    def set_series_monitored(self, tvdb_id, unwatched):
        series = self._get_series(tvdb_id)

        self._update_series(
            series | {
                "monitored": True,
                "seasons": list(
                    map(lambda season: season | {"monitored": True}, series["seasons"])
                ),
                "seasonFolder": len(unwatched.keys()) > 1,
            }
        )

        for episode in self._get_episodes(series["id"]):
            season_number = episode["seasonNumber"]
            episode_number = episode["episodeNumber"]

            monitored = (
                season_number in unwatched and episode_number in unwatched[season_number]
            )

            if episode["monitored"] != monitored:
                self._set_episode_monitored(episode["id"], monitored)

                if monitored:
                    self._command_episode_search(episode["id"])

    def refresh_series(self):
        self._command_refresh_series()


tv_track_time_request_handler = TVTrackTimeRequestHandler(
    "@tvTrackTimeApiUrl@", "@tvTrackTimeApiKey@"
)
sonarr_helper = SonarrHelper("@sonarApiUrl@", "@sonarApiKey@", "@sonarrRootDir@")

tvdb_ids = tv_track_time_request_handler.get_in_progress_tvdb_ids()
excluded_tvdb_ids = [@excludedTvdbIds@]

filtered_tvdb_ids = [
    tvdb_id for tvdb_id in tvdb_ids if tvdb_id not in excluded_tvdb_ids
]

sonarr_helper.delete_all_missing_series(filtered_tvdb_ids)

for tvdb_id in filtered_tvdb_ids:
    unwatched = tv_track_time_request_handler.get_unwatched_episodes(tvdb_id)

    if len(unwatched) > 0:
        sonarr_helper.add_series(tvdb_id)
        sonarr_helper.set_series_monitored(tvdb_id, unwatched)

sonarr_helper.refresh_series()
