# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=398667

let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "c93de71c316c1bbdcda1f52d27a60f586acdbc27";
      sha256 = "sha256:054r0bm4zmsrprjd4jswgnv8hzd0s66i39gsy36bmimjs4mw5bhq";
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
