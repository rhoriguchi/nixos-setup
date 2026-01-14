# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=479148

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "b4129a2ec7331300bbb2ae84b96afd10a58e639d";
      sha256 = "sha256:16l7q0aa8gv989r19bdcda2nj8vzqbgnwxryrfbkdc2fpdhk124w";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/misc/servarr/sonarr.nix" ];

  imports = [ "${src}/nixos/modules/services/misc/servarr/sonarr.nix" ];
}
