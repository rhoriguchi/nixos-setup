# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=340073

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "8e1c9eca9df4deb46322f02704578abd28635de7";
    sha256 = "sha256:0i4a9yq8gjv5hl4s5ykgcrc6zfwg8pf6g48ig5z69lzr36wbz4aj";
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
