# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=336419

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f07e57efe6b5fa231d872328cf0b6ba43c006a5f";
    sha256 = "sha256:1ds1n4ps7k9h7xf4krxbh6iip2i5rxl8b38jxrwv3rilcz1lxdvz";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/netdata.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netdata.nix" ];
}
