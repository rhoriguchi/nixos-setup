# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=460039

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "ec0041e93204387ce55e1d0b6b3028a3c63bcf2b";
      sha256 = "sha256:0k7q40s5gda0sidfhy9a0w4ip9hy55sdhhaq5lwbagvkvi2bd8xi";
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
