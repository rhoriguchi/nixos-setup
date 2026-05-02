# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=515299

let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "692911f6a0289844d4fc098cc85e24ef5cd6ec43";
      sha256 = "sha256:011jyyibiqlal9zjvv3s582gg32zvwdcw1jy0swvfk3i82i9qnyk";
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
