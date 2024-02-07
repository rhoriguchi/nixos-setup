# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=247828

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b610b282941a715e3b0257d801630674c50e0c9d";
    sha256 = "sha256:067vbqb46inrxg74bz52vmm5cqprkxlk5jd279sy4am4cb0cbm8n";
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
