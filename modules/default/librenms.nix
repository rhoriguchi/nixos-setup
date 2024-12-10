# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=359182

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "26abd85e2c1b78dc403cfa38aeb1efa31c5103f4";
    sha256 = "sha256:02y90bqw2h1m9pd5a45pmrml9r5lka9vawz0594gjsjirw6bcbhb";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/librenms.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/librenms.nix" ];
}
