# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=455222

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "14a5b3acfffaca73e4045c625fb1399128366e43";
      sha256 = "sha256:11vsvh7pfns1rlgpic73a599r60r5jp6sj2q0hzq0ckzj98gf20p";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/networking/bind.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/bind.nix" ];
}
