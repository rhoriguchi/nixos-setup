{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    sha256 = "079qkxdhvbsfn38a0lz8s26vlbssmzgsipx6fmwxjhk4dg4k2mzh";
  };
}
