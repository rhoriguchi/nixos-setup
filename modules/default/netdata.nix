# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=274577

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "218715f2ab9251b604be09ee063e54ca4adfb873";
    sha256 = "sha256:17zxa77m4pgj4h6liay83xapbhzi84wz8l3r0yjba812kc7nyzxx";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/netdata.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netdata.nix" ];
}
