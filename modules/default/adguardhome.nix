# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=247828

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "4e5ff3bef026c0979123df024aa275867d1ca1f6";
    sha256 = "sha256:1m5l621max558vsm76qjwswpf1i555i3g15p3r114m2nymza824q";
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
