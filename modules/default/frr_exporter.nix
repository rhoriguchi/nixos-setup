# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=335801

let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "2b139d3b1e99c2c5640f289345728acada409a35";
    sha256 = "sha256:1mg3v3wjkqfkzn91zi50s1b4cvhvmping157k5bal0vbbsi0h542";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in { imports = [ "${src}/nixos/modules/services/networking/frr_exporter.nix" ]; }
