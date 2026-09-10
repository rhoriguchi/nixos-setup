# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=561392

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "ae98b3f341a74ab75a0ce317ac6b8023a6fb3672";
      sha256 = "sha256-fWuIG/ybnxgGFcqJWtNFg9Jdmo3bwGp7Ikp16ej5SHI=";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/misc/ollama.nix" ];

  imports = [ "${src}/nixos/modules/services/misc/ollama.nix" ];
}
