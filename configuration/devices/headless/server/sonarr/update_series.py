import requests
from bs4 import BeautifulSoup


class TVTimeRequestHandler(object):
    BASE_URL = 'https://www.tvtime.com'

    def __init__(self, username, password):
        self._session = self._get_session()
        self._username = username
        self._password = password

        self._login()

    @staticmethod
    def _get_session():
        session = requests.session()
        session.headers.update({'User-agent': 'Mozilla/5.0'})
        return session

    def _login(self):
        response = self._session.post(f'{self.BASE_URL}/signin', data={
            'username': self._username,
            'password': self._password
        })

        if not response.ok:
            raise ValueError(
                f'TV Time returned status code {response.status_code} with reason: {response.reason}')

    def get_tvdb_ids(self):
        response = self._session.get(f'{self.BASE_URL}/en')

        soup = BeautifulSoup(response.content, 'html.parser')

        ids = set()
        for section in soup.find_all('section', id='to-watch'):
            text = section.find('h1').text.strip()

            if 'Watch next' in text or 'Not watched for a while' in text:
                for link in section.find_all('a', class_='secondary-link'):
                    ids.add(int(link.attrs['href'].split('/')[-1]))

        return ids

    def get_unwatched_episodes(self, tvdb_id):
        response = self._session.get(f'{self.BASE_URL}/show/{tvdb_id}')

        soup = BeautifulSoup(response.content, 'html.parser')

        unwatched = {}

        season_number = 1
        while True:
            unwatched_episodes = []

            season = soup.find(id=f'season{season_number}-content')
            if season is None:
                break

            for episode in season.find_all('li', {'class': 'episode-wrapper'}):
                if 'active' not in episode.find('a', {'class': 'watched-btn'}).attrs['class']:
                    episode_number = episode.find('span', {'class': 'episode-nb-label'}).text.strip()
                    unwatched_episodes.append(int(episode_number))

            if unwatched_episodes:
                unwatched[season_number] = unwatched_episodes

            season_number += 1

        return unwatched


class SonarrHelper(object):
    def __init__(self, host_url, api_key, root_dir):
        self._base_url = f'{host_url}/api/v3'
        self._session = self._get_session(api_key)
        self._root_dir = root_dir

        self._add_root_dir(root_dir)

        self._quality_profile_id = self.get_quality_profile_id('Any')
        self._language_profile_id = self.get_language_profile_id('English')
        self._tag_id = self._get_tag_id('tv_time')

    @staticmethod
    def _get_session(api_key):
        session = requests.session()
        session.headers.update({'X-Api-Key': api_key})
        return session

    def _get_all_quality_profiles(self):
        return self._session.get(f'{self._base_url}/qualityprofile') \
            .json()

    def get_quality_profile_id(self, name):
        match = next(filter(
            lambda profile: profile['name'].lower() == name.lower(),
            self._get_all_quality_profiles()
        ))

        if not match:
            raise ValueError(f'No quality profile found with name "{name}"')

        return match['id']

    def _get_all_language_profiles(self):
        return self._session.get(f'{self._base_url}/languageprofile') \
            .json()

    def get_language_profile_id(self, name):
        match = next(filter(
            lambda profile: profile['name'].lower() == name.lower(),
            self._get_all_language_profiles()
        ))

        if not match:
            raise ValueError(f'No language profile found with name "{name}"')

        return match['id']

    def _get_all_series(self):
        return self._session.get(f'{self._base_url}/series') \
            .json()

    def _lookup_series(self, tvdb_id):
        series = self._session.get(f'{self._base_url}/series/lookup', params={'term': f'tvdb:{tvdb_id}'}) \
            .json()

        if len(series) != 1:
            raise ValueError(f'More than one series found with tvdb_id "{tvdb_id}"')

        return series[0]

    def _add_root_dir(self, root_dir):
        self._session.post(f'{self._base_url}/rootFolder', json={'path': root_dir})

    def _get_tag_id(self, tag):
        return self._session.post(f'{self._base_url}/tag', json={'label': tag}) \
            .json()['id']

    def _get_series(self, tvdb_id):
        series = self._lookup_series(tvdb_id)

        if 'id' not in series:
            raise ValueError(f'Series with tvdb_id "{tvdb_id}" not added')

        return series

    def _add_series(self, series):
        self._session.post(f'{self._base_url}/series', json=series | {
            'rootFolderPath': self._root_dir,
            'qualityProfileId': self._quality_profile_id,
            'languageProfileId': self._language_profile_id,
            'tags': [self._tag_id]
        })

    def _update_series(self, series):
        if 'id' not in series:
            raise ValueError(f'Series with tvdb_id "{series["tvdbId"]}" not added')

        self._session.put(f'{self._base_url}/series', json=series | {
            'tags': list(set(series['tags'] + [self._tag_id]))
        })

    def _delete_series(self, id):
        self._session.delete(f'{self._base_url}/series/{id}', params={'deleteFiles': True})

    def _delete_episode_file(self, id):
        return self._session.delete(f'{self._base_url}/episodefile/${id}')

    def _get_episodes(self, series_id):
        return self._session.get(f'{self._base_url}/episode', params={'seriesId': series_id}) \
            .json()

    def _set_episode_monitored(self, id, monitored):
        self._session.put(f'{self._base_url}/episode/monitor', json={
            'episodeIds': [id],
            'monitored': monitored
        })

    def _command_refresh_series(self):
        self._session.post(f'{self._base_url}/command', json={'name': 'RefreshSeries'})

    def _command_episode_search(self, episode_id):
        self._session.post(f'{self._base_url}/command', json={
            'name': 'EpisodeSearch',
            'episodeIds': [episode_id]
        })

    def delete_all_missing_series(self, tvdb_ids):
        for series in self._get_all_series():
            if self._tag_id in series['tags'] and series['tvdbId'] not in tvdb_ids:
                print(f'Removing "{series["title"]}"')
                self._delete_series(series['id'])

    def add_series(self, tvdb_id):
        series = self._lookup_series(tvdb_id)

        if 'id' not in series:
            print(f'Adding "{series["title"]}"')

            self._add_series(series | {'addOptions': {'monitor': 'none'}})

    def set_series_monitored(self, tvdb_id, unwatched):
        series = self._get_series(tvdb_id)

        self._update_series(series | {
            'monitored': True,
            'seasons': list(map(lambda season: season | {'monitored': True}, series['seasons'])),
            'seasonFolder': len(unwatched.keys()) > 1
        })

        for episode in self._get_episodes(series['id']):
            season_number = episode['seasonNumber']
            episode_number = episode['episodeNumber']

            monitored = True if season_number in unwatched and episode_number in unwatched[season_number] else False

            if episode['monitored'] != monitored:
                self._set_episode_monitored(episode['id'], monitored)

                if monitored:
                    self._command_episode_search(episode['id'])

                if not monitored and episode['episodeFileId'] != 0:
                    self._delete_episode_file(episode['episodeFileId'])

    def refresh_series(self):
        self._command_refresh_series()


tv_time_request_handler = TVTimeRequestHandler('@tvTimeUsername@', '@tvTimePassword@')
sonar_helper = SonarrHelper('@sonarApiUrl@', '@sonarApiKey@', '@sonarrRootDir@')

tvdb_ids = tv_time_request_handler.get_tvdb_ids()

sonar_helper.delete_all_missing_series(tvdb_ids)

for tvdb_id in tvdb_ids:
    sonar_helper.add_series(tvdb_id)

    unwatched = tv_time_request_handler.get_unwatched_episodes(tvdb_id)
    sonar_helper.set_series_monitored(tvdb_id, unwatched)

sonar_helper.refresh_series()
