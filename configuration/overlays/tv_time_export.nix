{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    sha256 = "sha256-ksBsqqhwKOh4C7n7+HcY0rUFEaXPtUc4Vc7+SV4Wzj8=";
  };
}
