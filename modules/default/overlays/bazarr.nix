# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=519655

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "215cf43531f0449535bf3818562675c817bda11b";
      sha256 = "sha256:1v9rkdr7f2xi4m6rr7fx7d60xmybk9bmzrxpyj8fb1n5dmlssqi2";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/misc/bazarr.nix" ];

  imports = [ "${src}/nixos/modules/services/misc/bazarr.nix" ];
}
