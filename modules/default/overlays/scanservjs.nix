# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=492318

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "837903320aa76d872fa33c801984f33131209a8f";
      sha256 = "sha256:0s1h385m7bpwhpgfbpbs4572348nyz6wjh3kqksxzsk38ci36mnp";
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
    (_: prev: {
      scanservjs = prev.callPackage (import "${src}/pkgs/by-name/sc/scanservjs/package.nix") { };
    })
  ];
}
