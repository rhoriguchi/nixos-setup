import json
import os
import re
from typing import Dict, cast, List

from audio_converter.shell_helper import ShellHelper


class MediainfoWrapper():
    def __init__(self):
        self._mediainfo_path = self._get_mediainfo_path()
        self._check_version()

    def _get_version(self) -> float:
        output = ShellHelper.cmd(f'{self._mediainfo_path} --Version')

        if match := re.search(r'MediaInfoLib\s+-\s+v(\d+(?:\.\d+)?)', output):
            return float(match.group(1))

        raise RuntimeError('Could not get version of mediainfo')

    def _check_version(self) -> None:
        if self._get_version() < 20:
            raise RuntimeError('Mediainfo needs to be at least version 20')

    @staticmethod
    def _get_mediainfo_path() -> str:
        for path in os.environ['PATH'].split(':'):
            if os.path.isdir(path) and 'mediainfo' in os.listdir(path):
                return os.path.join(path, 'mediainfo')

        raise RuntimeError('mediainfo not on path')

    def _get_mediainfo(self, path: str) -> Dict[str, any]:
        output = ShellHelper.cmd(f'{self._mediainfo_path} --Output=JSON -f "{path}"')

        return json.loads(output)['media']['track']

    def _get_audio_info(self, path: str) -> List[Dict[str, any]]:
        audio_info = []

        for mediainfo in self._get_mediainfo(path):
            if mediainfo['@type'] == 'Audio':
                audio_info.append(mediainfo)

        return cast(
            List[Dict[str, any]],
            audio_info
        )

    def get_audio_formats(self, path) -> List[str]:
        audio_formats = []

        for audio_info in self._get_audio_info(path):
            if 'InternetMediaType' in audio_info:
                audio_format = audio_info['InternetMediaType'].split('/')[-1]
            else:
                audio_format = audio_info['Format'].lower()

            audio_formats.append(audio_format)

        if len(audio_formats) > 0:
            return audio_formats

        raise ValueError(f'"{path}" has no audio tracks')
