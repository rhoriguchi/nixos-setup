# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=492318

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "dc6127f7e08ccc0e889ea20e2aa28612fe7686d4";
      sha256 = "sha256:0m7h6kz2djbww8x2xvxc7k041ghlab6nllp2bhmirahfc8r0z3p5";
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
    (_: super: {
      scanservjs = super.callPackage (import "${src}/pkgs/by-name/sc/scanservjs/package.nix") { };
    })
  ];
}
