# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=249806

let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "c861052eab51de685f2286ce75d6e67395f6eae5";
    sha256 = "sha256:1j3drcp4mizf90dcpvnfajx1b49m8ijfq7w6a53kyfgx22r1x51i";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  imports = [ "${src}/nixos/modules/services/hardware/scanservjs.nix" ];

  nixpkgs.overlays = [ (_: super: { scanservjs = super.callPackage "${src}/pkgs/applications/graphics/scanservjs" { }; }) ];
}
