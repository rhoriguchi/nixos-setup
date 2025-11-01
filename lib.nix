{ lib, ... }:
{
  getImports =
    let
      getFiles = dir: lib.attrNames (builtins.readDir dir);
      filter =
        file:
        if lib.pathIsDirectory file then
          lib.elem "default.nix" (getFiles file)
        else
          lib.hasSuffix ".nix" file && !(lib.hasSuffix "default.nix" file);
    in
    dir: lib.filter filter (map (file: dir + "/${file}") (getFiles dir));

  relativeToRoot = lib.path.append ./.;

  # Adapted from https://github.com/hmajid2301/nixicle/blob/8e8f5b1f2612a441b9f9da3e893af60774448836/lib/deploy/default.nix
  mkDeploy =
    {
      deploy-rs,
      nixosConfigurations,
      overrides ? { },
    }:
    let
      hosts = nixosConfigurations;
      names = lib.attrNames hosts;
    in
    {
      nodes = lib.foldl (
        result: name:
        let
          inherit (host.pkgs.stdenv.hostPlatform) system;
          host = hosts.${name};
        in
        result
        // lib.optionalAttrs (overrides.${name}.deploy or true) {
          "${name}" = {
            hostname = lib.toLower (overrides.${name}.hostname or "${name}");

            profiles.system = {
              sshUser = "root";
              path = deploy-rs.lib.${system}.activate.nixos host;
            }
            // (overrides.${name}.extraOptions or { });
          };
        }
      ) { } names;
    };
}
