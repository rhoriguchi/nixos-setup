# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=558042

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "602810e3ddb2a4e91af8b9324d428c3769e1585a";
      sha256 = "sha256-I/J4Ca6RM2sm3g5MSEY49sjCVOY0MaMlsXR5PvpV/XU=";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/networking/headplane.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/headplane.nix" ];
}
