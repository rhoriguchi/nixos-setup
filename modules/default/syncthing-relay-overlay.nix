# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=513794

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "cc5425a49c9698c12d5b8beb63d95e76612c757c";
      # rev = "8d600a72d935e4b2b0b34747cce86c4660832f37";
      sha256 = "sha256:0aa7ij73cd8940isvhqvx06mg302xc56hwy5wfgjma63z6jg9lnp";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/networking/syncthing-relay.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/syncthing-relay.nix" ];
}
