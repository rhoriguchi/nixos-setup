# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=519655

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "ee41ab73e7042b573e67f61107c9679acc742816";
      sha256 = "sha256:0lsbfyx8jz2iiwnx7rb24sbvg9x1bhm2dpa6fpzsscigmx06f56v";
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
