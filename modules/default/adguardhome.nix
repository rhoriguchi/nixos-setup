# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=247828

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f57fb1ad8e4caa6d25c86a1b94961cb7b0dbf165";
    sha256 = "sha256:06s86adx93lrsvp6i0j7ja49v5zza985q0zfgag3hwlh6n9xwvb2";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/networking/adguardhome.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/adguardhome.nix" ];

  nixpkgs.overlays = [ (_: super: { adguardhome = super.callPackage (import "${src}/pkgs/servers/adguardhome") { }; }) ];
}
