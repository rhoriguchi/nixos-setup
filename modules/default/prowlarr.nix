# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=2866714879

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "7cc8786f893998069a4ba78b15f81e4c5a5128e3";
    sha256 = "sha256:06hcswlrgh9k7pic7w270f95vp53wz6zhjipzyvz0g2wxd98n8ij";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/misc/servarr/prowlarr.nix" ];

  imports = [ "${src}/nixos/modules/services/misc/servarr/prowlarr.nix" ];
}
