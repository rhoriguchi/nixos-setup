# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=410815

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "4d7c9aa268b5840149348357f38b3f97f9efaaeb";
    sha256 = "sha256:11ra9d4vdmgbwhdnzlllf7qb55kq59y3l3lj4k5j4w0qdwqkgvfi";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/netdata.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netdata.nix" ];

  nixpkgs.overlays = [ (_: super: { netdata = super.callPackage "${src}/pkgs/tools/system/netdata" { protobuf = super.protobuf_21; }; }) ];
}
