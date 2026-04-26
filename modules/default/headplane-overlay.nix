# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=398667

let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "9ffc6aa12ea89c2e5307ccd32984efeff1dc2ec9";
      sha256 = "sha256:1spwf9d5zfgn1rjviaihlcg3cxhaqcclg5k70s1znpcb42nwgysr";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  imports = [ "${src}/nixos/modules/services/networking/headplane.nix" ];

  nixpkgs.overlays = [
    (_: prev: {
      headplane = prev.callPackage "${src}/pkgs/by-name/he/headplane/package.nix" { };
      headplane-agent = prev.callPackage "${src}/pkgs/by-name/he/headplane-agent/package.nix" { };
    })
  ];
}
