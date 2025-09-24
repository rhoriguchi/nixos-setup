# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=444629

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "78df37f04ddef8c19c99f847bae16559b1749159";
      sha256 = "sha256:07ab9aw8rkazy1p7750fa1bbdcqpg731yihpzzg70qmiyly3jq8g";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/security/doas.nix" ];

  imports = [ "${src}/nixos/modules/security/doas.nix" ];
}
