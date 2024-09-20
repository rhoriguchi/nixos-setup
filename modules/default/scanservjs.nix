# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=249806

let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "7104e41f3ad8ac5b0d5429e249c5b4088a7d0b9a";
    sha256 = "sha256:1iaxj0w5xphxfp0xw8sqkix0v9nf86i89k26xb30iazd9aw0jq06";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  imports = [ "${src}/nixos/modules/services/hardware/scanservjs.nix" ];

  nixpkgs.overlays = [ (_: super: { scanservjs = super.callPackage "${src}/pkgs/by-name/sc/scanservjs/package.nix" { }; }) ];
}
