{ python3Packages, fetchFromGitHub, mediainfo, ffmpeg }:
python3Packages.buildPythonApplication rec {
  pname = "audio-converter";
  version = "1.0.0";

  src = ./src;

  propagatedBuildInputs = [ mediainfo ffmpeg ];
}
