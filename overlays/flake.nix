{
  description = "Local package overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    easy-floorplan = {
      url = "github:NixOS/nixpkgs/pull/591874/head";
      flake = false;
    };

    gamedig = {
      url = "github:NixOS/nixpkgs/pull/467867/head";
      flake = false;
    };

    netdata = {
      url = "github:NixOS/nixpkgs/pull/590575/head";
      flake = false;
    };

    superfile = {
      url = "github:NixOS/nixpkgs/pull/591404/head";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      overlays.default = nixpkgs.lib.composeManyExtensions [
        (_: prev: {
          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
          gamedig = prev.callPackage (import "${inputs.gamedig}/pkgs/by-name/ga/gamedig/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=591874
          home-assistant-custom-lovelace-modules = prev.home-assistant-custom-lovelace-modules // {
            easy-floorplan =
              prev.callPackage
                (import "${inputs.easy-floorplan}/pkgs/servers/home-assistant/custom-lovelace-modules/easy-floorplan/package.nix")
                { };
          };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=590575
          netdata = prev.callPackage (import "${inputs.netdata}/pkgs/tools/system/netdata") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=591404
          superfile =
            prev.callPackage (import "${inputs.superfile}/pkgs/by-name/su/superfile/package.nix")
              { };
        })

        # TODO remove when resolved
        (_: prev: {
          # - This version of IDEA has multiple known security vulnerabilities, see NIXPKGS-2026-2269: https://tracker.security.nixos.org/issues/NIXPKGS-2026-2269.
          #   The package `jetbrains.idea-oss` is currently not receiving updates in nixpkgs, consider using `jetbrains.pycharm`.
          # - This version of PyCharm has multiple known security vulnerabilities, see NIXPKGS-2026-2269: https://tracker.security.nixos.org/issues/NIXPKGS-2026-2269.
          #   The package `jetbrains.pycharm-oss` is currently not receiving updates in nixpkgs, consider using `jetbrains.pycharm`.
          jetbrains = prev.jetbrains // {
            idea-oss = prev.jetbrains.idea;
            pycharm-oss = prev.jetbrains.pycharm;
          };
        })

        (_: prev: {
          wallpaper = prev.callPackage ./wallpaper { };
        })
      ];
    };
}
