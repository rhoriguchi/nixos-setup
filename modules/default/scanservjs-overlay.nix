# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=492318

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "9d171f0f9fd8260b7e0662bc6691303583ab353d";
      sha256 = "sha256:1wlqfrb19nisi7phl87gbv5clcmli117m6r1waq5cbxdln042202";
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
