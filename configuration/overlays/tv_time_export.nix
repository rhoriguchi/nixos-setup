{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.18";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    hash = "sha256-s+ggdipaA1g3rj3X7BCzm4GxLjfv/Rb7fE9/XyHYN8I=";
  };
}
