# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=359182

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "d7a016108bb4cdbf208a97c5906f3c87343b7635";
    sha256 = "sha256:09jn0n2gban9z107n4mzdnlppankj12pr9idfki31cygh33z94an";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/librenms.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/librenms.nix" ];
}
