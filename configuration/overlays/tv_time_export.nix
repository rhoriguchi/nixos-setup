{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    sha256 = "0s7mnpbakxrkwfyff4wm8y1g65d3xy0zlgnzdvdp7mhrrw5wc6iy";
  };

  # TODO for some reason dependencies from "requests==2.26.0" are correctly detected
  requirementsExtra = ''
    certifi>=2017.4.17
    charset-normalizer~=2.0.0
    idna<4,>=2.5
    urllib3<1.27,>=1.21.1
  '';
}
