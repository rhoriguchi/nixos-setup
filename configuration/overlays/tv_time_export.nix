{ mach-nix, fetchFromGitHub }:
mach-nix.buildPythonApplication rec {
  pname = "tv_time_export";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "rhoriguchi";
    repo = pname;
    rev = version;
    sha256 = "1fynx5pqpg9hawi1kwkkx2s6zg964jrlhya77p618f67sdgpn5gi";
  };
}
