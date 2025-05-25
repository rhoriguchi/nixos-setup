# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=2866714879

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "71d5f0f591c7ec68d2ca476aee4f57039cf51fd6";
    sha256 = "sha256:1p59s8bvrbhn24wwp3lp8z40hdvnknn5lg68x9zgzs8bi9v8y76f";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/misc/servarr/prowlarr.nix" ];

  imports = [ "${src}/nixos/modules/services/misc/servarr/prowlarr.nix" ];
}
