# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=455222

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "33eef88f24766c52b72a5f5709c0bf3f24e244db";
      sha256 = "sha256:18r19ivh73gx5lqc7d2373vcysqzxyhjbmha8gw2k62064zfqxyy";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/networking/bind.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/bind.nix" ];
}
