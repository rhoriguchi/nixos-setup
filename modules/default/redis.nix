# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=345327

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "cb31bd47554842da3a8dfda2f74981eebf2ad914";
    sha256 = "sha256:1nykz8kc85fdyrsqzas4k5qnhj5fpyahjm6v99ac2ccjsac4ckrb";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/databases/redis.nix" ];

  imports = [ "${src}/nixos/modules/services/databases/redis.nix" ];
}
