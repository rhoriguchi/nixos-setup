{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.20";

  ignoreDataOutdated = true;

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    hash = "sha256-TBryj0cu02u7Jte9q9LNnEvsNmkS1i3goosAkf7Nlis=";
  };
}
