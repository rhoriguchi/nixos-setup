# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=460039

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "2a9a5b4c1e0c1e3be6d9ed94e7ab61b90b825f87";
      sha256 = "sha256:1xqwixl6sv7h1cm60kzmbp8hiz53la6c64akrbk8a4y0bkv828rb";
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
