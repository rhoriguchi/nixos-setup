# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=529590

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "dc0c61e4450744093395789b6ea3192e1e81f341";
      sha256 = "sha256:0ll4sk6n9jkfz4v84hdbsaf2gjaszhi1rk96k6l5gbwxfhl03gjd";
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
