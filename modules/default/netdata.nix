# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=340073
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=346228

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "a5483bacb3ce27264955e32d7303410dde76a7a0";
    sha256 = "sha256:1j4wi375awwa3lkiy41k4myay27lxhl54pp8cwfawxx4cgkmm307";
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
