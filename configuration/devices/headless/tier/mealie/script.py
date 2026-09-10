import json
import sys
import time

import requests

BASE_URL = "@baseUrl@"

DEFAULT_USERNAME = "@defaultUsername@"
DEFAULT_PASSWORD = "@defaultPassword@"
NEW_PASSWORD = "@newPassword@"

SETUP_USER_NAME = "@setupUserName@"
SETUP_USER_EMAIL = "@setupUserEmail@"

# Each entry: {"name", "baseUrl", "apiKey", "model", "default"?, "image"?, "audio"?}.
# The boolean role flags select which of Mealie's defaultProviderId/imageProviderId/
# audioProviderId slots this provider is assigned to; a provider may fill more than one.
AI_PROVIDERS = json.loads("""@aiProviders@""")


class MealieClient(object):
    def __init__(self, base_url):
        self._base_url = base_url.rstrip("/")
        self._session = requests.session()

    def wait_until_ready(self, interval=1):
        while True:
            try:
                response = self._session.get(f"{self._base_url}/api/app/about")
                if response.ok:
                    return
            except requests.exceptions.RequestException:
                pass

            time.sleep(interval)

    def login(self, username, password):
        response = self._session.post(
            f"{self._base_url}/api/auth/token",
            data={"username": username, "password": password},
        )

        if not response.ok:
            return None

        return response.json().get("access_token")

    def authenticate(self, token):
        self._session.headers.update({"Authorization": f"Bearer {token}"})

    def update_admin_password(self, current_password, new_password):
        response = self._session.put(
            f"{self._base_url}/api/users/password",
            json={"currentPassword": current_password, "newPassword": new_password},
        )
        response.raise_for_status()

    def update_setup_user(self, name, email):
        self_user = self._session.get(f"{self._base_url}/api/users/self").json()

        response = self._session.put(
            f"{self._base_url}/api/users/{self_user['id']}",
            json=self_user | {"fullName": name, "email": email},
        )
        response.raise_for_status()

    def update_household_preferences(self, first_day_of_week=1):
        preferences = self._session.get(
            f"{self._base_url}/api/households/preferences"
        ).json()

        response = self._session.put(
            f"{self._base_url}/api/households/preferences",
            json=preferences | {"firstDayOfWeek": first_day_of_week},
        )
        response.raise_for_status()

    def update_group_preferences(self, show_announcements=True):
        preferences = self._session.get(
            f"{self._base_url}/api/groups/preferences"
        ).json()

        response = self._session.put(
            f"{self._base_url}/api/groups/preferences",
            json=preferences | {"showAnnouncements": show_announcements},
        )
        response.raise_for_status()

    def _get_ai_provider_settings(self):
        return self._session.get(
            f"{self._base_url}/api/groups/ai-providers/settings"
        ).json()

    @staticmethod
    def _find_ai_provider_id(settings, name):
        return next(
            (
                provider["id"]
                for provider in settings["providers"]
                if provider["name"] == name
            ),
            None,
        )

    def create_ai_provider(self, name, base_url, api_key, model, timeout=300):
        provider = {
            "name": name,
            "baseUrl": base_url,
            "apiKey": api_key,
            "model": model,
            "timeout": timeout,
        }

        settings = self._get_ai_provider_settings()
        provider_id = self._find_ai_provider_id(settings, name)

        if provider_id is not None:
            response = self._session.put(
                f"{self._base_url}/api/groups/ai-providers/providers/{provider_id}",
                json=provider,
            )
            response.raise_for_status()
        else:
            response = self._session.post(
                f"{self._base_url}/api/groups/ai-providers/providers", json=provider
            )
            response.raise_for_status()
            provider_id = response.json()["id"]

        return provider_id

    def delete_ai_provider(self, provider_id):
        response = self._session.delete(
            f"{self._base_url}/api/groups/ai-providers/providers/{provider_id}"
        )
        response.raise_for_status()

    def apply_ai_providers(self, providers):
        default_id = image_id = audio_id = None
        first_id = None
        configured_names = {provider["name"] for provider in providers}

        for provider in providers:
            provider_id = self.create_ai_provider(
                provider["name"], provider["baseUrl"], provider["apiKey"], provider["model"]
            )

            if first_id is None:
                first_id = provider_id

            if provider.get("default"):
                default_id = provider_id
            if provider.get("image"):
                image_id = provider_id
            if provider.get("audio"):
                audio_id = provider_id

        if default_id is None:
            default_id = first_id
        if image_id is None:
            image_id = first_id
        if audio_id is None:
            audio_id = first_id

        response = self._session.put(
            f"{self._base_url}/api/groups/ai-providers/settings",
            json={
                "defaultProviderId": default_id,
                "imageProviderId": image_id,
                "audioProviderId": audio_id,
            },
        )
        response.raise_for_status()

        settings = self._get_ai_provider_settings()
        for provider in settings["providers"]:
            if provider["name"] not in configured_names:
                self.delete_ai_provider(provider["id"])


def main():
    client = MealieClient(BASE_URL)
    client.wait_until_ready()

    token = client.login(DEFAULT_USERNAME, DEFAULT_PASSWORD)
    if token is not None:
        client.authenticate(token)
        client.update_admin_password(DEFAULT_PASSWORD, NEW_PASSWORD)

    token = client.login(DEFAULT_USERNAME, NEW_PASSWORD)
    if token is None:
        sys.exit("mealie-setup: could not authenticate as bootstrap admin")

    client.authenticate(token)

    client.update_setup_user(SETUP_USER_NAME, SETUP_USER_EMAIL)
    client.update_household_preferences()
    client.update_group_preferences(show_announcements=False)

    client.apply_ai_providers(AI_PROVIDERS)


if __name__ == "__main__":
    main()
