import os
import re
from typing import Dict

from audio_converter.shell_helper import ShellHelper


class FfmpegWrapper():
    def __init__(self):
        self._ffmpeg_path = self._get_ffmpeg_path()

    @staticmethod
    def _get_ffmpeg_path() -> str:
        for path in os.environ['PATH'].split(':'):
            if os.path.isdir(path) and 'ffmpeg' in os.listdir(path):
                return os.path.join(path, 'ffmpeg')

        raise RuntimeError('ffmpeg not on path')

    def _get_supported_formats(self) -> Dict[str, str]:
        output = ShellHelper.cmd(f'{self._ffmpeg_path} -formats')

        supported_formats = {}

        for supported_format in output.split('--')[1].split('\n'):
            if match := re.search(r'\s\w+\s+([\w,_]+)\s+(.*)', supported_format):
                supported_formats[match[1]] = match[2]

        return supported_formats

    def format_supported(self, format: str) -> bool:
        return format in self._get_supported_formats()

    def convert(self, path: str, to_format: str) -> None:
        splits = path.split('.')
        output_path = '.'.join(splits[:-1] + ['converted', splits[-1]])

        ShellHelper.cmd(
            f'{self._ffmpeg_path} -hwaccel auto -y -i "{path}" -map 0 -c:s copy -c:v copy -c:a {to_format} "{output_path}"')

        ShellHelper.cmd(f'mv --force "{output_path}" "{path}"')
