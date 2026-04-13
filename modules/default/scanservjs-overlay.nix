# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=492318

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "f8e81a68e62a6ce1da903e8448f70ca0c659a5af";
      sha256 = "sha256:01cpicdwfnphysb2l641fx86wzyn8ah81249piav7q4smszny4j6";
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
