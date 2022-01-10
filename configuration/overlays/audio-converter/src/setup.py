from setuptools import setup, find_packages

setup(
    name='audio-converter',
    version='1.0.0',
    entry_points={
        'console_scripts': ['audio-converter = audio_converter.__main__:main'],
    },
    install_requires=[],
    packages=find_packages(),
    python_requires='>=3.8'
)
