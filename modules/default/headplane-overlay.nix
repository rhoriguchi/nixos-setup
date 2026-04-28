# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=398667

let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "aee6662b429cf1d5b349cb6234aeddcaf1eae481";
      sha256 = "sha256:00dcv7aflap1lnlhbzr08ij6fw3imab9v5xjg3l0np1fr4nq56jj";
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
