# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=507378

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "107967491bd12b3ef536e5f5e23cdfa18216f1e1";
      sha256 = "sha256:1x34rz4ipbd2b88n9hj4xw8izr1fgssw6v11vn9yk2qh868wxlis";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/misc/bazarr.nix" ];

  imports = [ "${src}/nixos/modules/services/misc/bazarr.nix" ];
}
