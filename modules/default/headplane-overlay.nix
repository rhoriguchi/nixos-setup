# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=398667

let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "ded103369bda58eb03b9d4b7a879ff1e7cf781b4";
      sha256 = "sha256:1fx7s631722ahx9kvmyhj371sg1nn12l2dd8zkazzjgfbln2lhxb";
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
