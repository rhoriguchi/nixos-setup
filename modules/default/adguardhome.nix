# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=247828

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "90e395ce1e348173fe8577447b00b131d146500e";
    sha256 = "sha256:0khgm64ka7f1jx6ir1q3biwmp5nd5hll5c3ap11fk7fw0nj77kv9";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/networking/adguardhome.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/adguardhome.nix" ];

  nixpkgs.overlays = [ (_: super: { adguardhome = super.callPackage (import "${src}/pkgs/servers/adguardhome") { }; }) ];
}
