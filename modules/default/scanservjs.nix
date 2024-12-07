# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=249806

let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f2b8864a62f380c473e4f1c289db428b27deeb79";
    sha256 = "sha256:0fmi7vqdv86v1gc3m6a6gw91dzzxcmzb04fqcxw918b9k2w7qgrc";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  imports = [ "${src}/nixos/modules/services/hardware/scanservjs.nix" ];

  nixpkgs.overlays = [ (_: super: { scanservjs = super.callPackage "${src}/pkgs/by-name/sc/scanservjs/package.nix" { }; }) ];
}
