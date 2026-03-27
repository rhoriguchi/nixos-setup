# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=398667

let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "a06b660159277eb54827756198db414fb63a0b56";
      sha256 = "sha256:09y70zgmqcm6w9wrkgglnhr9lnjqas2y5jv7prrmnfd2sv1cgdi2";
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
