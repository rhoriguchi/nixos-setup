# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=340073

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "4e7df2caa4c1979a656a325fc08ab8a4694ea6ba";
    sha256 = "sha256:0nksibckqm7r7zm82152plp6isjyjhb2mnlxcr1sp6wl6z8rfr4k";
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
