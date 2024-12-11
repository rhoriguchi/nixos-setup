# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=359182

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "2719fd3a82dcd10a452edcb171aff50e988dd2b7";
    sha256 = "sha256:0aw9rm4gaj4ygfx92q9mnik2km081s1ahqq84806yl1ira9ffrf1";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/librenms.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/librenms.nix" ];
}
