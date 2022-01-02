import logging
import math
import mimetypes
import os
from multiprocessing.dummy import Pool as ThreadPool
from typing import List, Tuple

from audio_converter.ffmpeg_wrapper import FfmpegWrapper
from audio_converter.mediainfo_wrapper import MediainfoWrapper

logger = logging.getLogger(__name__)


class AudioConverter():
    def __init__(self):
        self._mediainfo = MediainfoWrapper()
        self._ffmpeg = FfmpegWrapper()

    @staticmethod
    def _get_files(path: str) -> List[str]:
        if os.path.isdir(path):
            return sorted([os.path.join(path, content) for content in os.listdir(path)])

        return []

    def _get_videos(self, path: str) -> List[str]:
        videos = []

        for file in self._get_files(path):
            if os.path.isfile(file):
                (mime, encoding) = mimetypes.guess_type(file)

                if mime and 'video' in mime.split('/'):
                    videos.append(file)
            else:
                videos = videos + self._get_videos(file)

        return videos

    def _video_needs_converting(self, values: Tuple[str, str]) -> Tuple[str, bool]:
        (path, from_format) = values

        try:
            return path, from_format in self._mediainfo.get_audio_formats(path)
        except Exception:
            return path, False

    def _convert_video(self, values: Tuple[str, str]) -> None:
        (path, to_format) = values

        logger.info('Converting "{}"'.format(path))

        try:
            self._ffmpeg.convert(path, to_format)
        except Exception as ex:
            logger.error('Failed to convert "{}" with error message: {}'.format(path, ex))

    def convert(self, path: str, from_format: str, to_format: str) -> None:
        if not self._ffmpeg.format_supported(from_format):
            raise ValueError(f'ffmpeg does not support from "{from_format}"')

        if not self._ffmpeg.format_supported(to_format):
            raise ValueError(f'ffmpeg does not support from "{to_format}"')

        logger.info('Audio converter started')

        videos = self._get_videos(path)
        count = len(videos)

        if count == 1:
            logger.info('Found {} video'.format(len(videos)))
        else:
            logger.info('Found {} videos'.format(len(videos)))

        videos_that_need_converting = self._get_videos_that_need_converting(videos, from_format)
        count = len(videos_that_need_converting)

        if count == 1:
            logger.info('{} video need converting'.format(count))
        else:
            logger.info('{} videos need converting'.format(count))

        if count > 0:
            with ThreadPool(math.floor(os.cpu_count() / 3)) as pool:
                pool_values = list(map(lambda value: (value, to_format), videos_that_need_converting))
                pool.map(self._convert_video, pool_values)

        logger.info('Audio converter finished')

    def _get_videos_that_need_converting(self, paths: List[str], from_format: str) -> List[str]:
        with ThreadPool(os.cpu_count()) as pool:
            pool_values = list(map(lambda value: (value, from_format), paths))
            values = list(pool.map(self._video_needs_converting, pool_values))

        values = list(filter(lambda value: value[1] is True, values))
        values = list(map(lambda value: value[0], values))

        return values
