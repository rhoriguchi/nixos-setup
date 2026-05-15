# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=501100

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "8f960c365db087e2712b4c383146802be339095d";
      sha256 = "sha256:03df4chchnw44q2lsmbsq8vim4cfl7jqcf720knhkg9j7i3dmif2";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/networking/pihole-ftl.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/pihole-ftl.nix" ];
}
