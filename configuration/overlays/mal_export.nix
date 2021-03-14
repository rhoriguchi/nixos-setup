{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "mal_export";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    sha256 = "1nvgp60f07phxnkb6lp80is458wz0nqxpimry4p1bgd74fx8v840";
  };
}
