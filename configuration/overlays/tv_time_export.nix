{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.15";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    hash = "sha256-D5u6aat/3nlMZEEDCBdDRomUnS4pmkt46S1nwsy1akI=";
  };
}
