{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.19";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    hash = "sha256-ev02l0ZTj71i63A9UI3xzCX0o98VFNJwf8+e3Cye5eM=";
  };
}
