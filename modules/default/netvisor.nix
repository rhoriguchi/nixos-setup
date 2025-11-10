# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=460039

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "a06278260f3ba35953fab09eff72b998c8b84ea6";
      sha256 = "sha256:1vgcy0c4jzr99xxw96wlz4hzkl4iwjcgq7jcsrz2yjb7phsf2wkl";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/monitoring/netvisor.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netvisor.nix" ];

  nixpkgs.overlays = [
    (_: super: { netvisor = super.callPackage "${src}/pkgs/by-name/ne/netvisor/package.nix" { }; })
  ];
}
