# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=410501

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "4ddfe8e0917cf22c30cfc0b8c2a8b964eedc23fd";
      sha256 = "sha256:043gah20gjxk631wddbqd90dszld8mbblin02a4xzxjmjdd66jqp";
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
