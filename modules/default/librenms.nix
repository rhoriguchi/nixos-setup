# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=359182

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "cf4d89e473867d68587cfe098e0725194eddf149";
    sha256 = "sha256:0an0xa61wpgympk391kyn6pdmx4jnbiyapcr193kc9qk9r3x3iaz";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/librenms.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/librenms.nix" ];
}
