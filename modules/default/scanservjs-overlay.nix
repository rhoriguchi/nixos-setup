# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=492318

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "cb63144f5dff4fae01d8eaccbeaba916348dbc8a";
      sha256 = "sha256:115yr8apxh9di840bf8hhxipq24dk8an4zhgd1mx7j0571vyqpzc";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/hardware/scanservjs.nix" ];

  imports = [ "${src}/nixos/modules/services/hardware/scanservjs.nix" ];

  nixpkgs.overlays = [
    (_: super: {
      scanservjs = super.callPackage (import "${src}/pkgs/by-name/sc/scanservjs/package.nix") { };
    })
  ];
}
