# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=398667

let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "0b8c71c22b4d8bb345d45ee2d649c0ad45884a1e";
      sha256 = "sha256:03sdz9zsz95566kh4ha5z8dnxjvjr47z70dpdwivh8xfv7dz88q4";
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
    (_: super: {
      headplane = super.callPackage "${src}/pkgs/by-name/he/headplane/package.nix" { };
      headplane-agent = super.callPackage "${src}/pkgs/by-name/he/headplane-agent/package.nix" { };
    })
  ];
}
