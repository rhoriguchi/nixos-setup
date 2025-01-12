# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=373068

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b823155301571db7869af88a1d6ec6fc764d64ca";
    sha256 = "sha256:1kd945c57caga0cgx9zgxz35kdjddra53qq1zm1j2rp6hf9kmbsv";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/networking/dnsmasq.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/dnsmasq.nix" ];
}
