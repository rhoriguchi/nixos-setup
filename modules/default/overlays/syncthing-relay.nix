# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=513794

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "7a310d8f6557ce447cd4ea71cd1348f433d63013";
      sha256 = "sha256:0f81yy7lc5nigxdbix8iiiik1rhk8j6w20cp72240hkwcwck8dnh";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/networking/syncthing-relay.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/syncthing-relay.nix" ];
}
