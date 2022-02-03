import logging
import sys

from audio_converter.audio_converter import AudioConverter


def main():
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))

    logging.basicConfig(level=logging.INFO, handlers=[console_handler])

    argv = sys.argv

    logger = logging.getLogger(__name__).info(f'Audio converter called with parameter "{argv[1:]}"')

    if len(argv) != 4:
        raise ValueError('3 parameters need to be provided')

    path = argv[1]
    from_format = argv[2]
    to_format = argv[3]

    AudioConverter().convert(path, from_format, to_format)


if __name__ == '__main__':
    main()
