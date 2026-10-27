{
  description = "Local package overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    diffnav = {
      url = "github:NixOS/nixpkgs/pull/579731/head";
      flake = false;
    };

    gamedig = {
      url = "github:NixOS/nixpkgs/pull/467867/head";
      flake = false;
    };

    mcp-nixos.url = "github:utensils/mcp-nixos";

    mealie = {
      url = "github:NixOS/nixpkgs/pull/578307/head";
      flake = false;
    };

    netdata = {
      url = "github:NixOS/nixpkgs/pull/578946/head";
      flake = false;
    };

    onedrive = {
      url = "github:NixOS/nixpkgs/pull/578257/head";
      flake = false;
    };

    tautulli = {
      url = "github:NixOS/nixpkgs/pull/577581/head";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      overlays.default = nixpkgs.lib.composeManyExtensions [
        (_: prev: {
          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=579731
          diffnav = prev.callPackage (import "${inputs.diffnav}/pkgs/by-name/di/diffnav/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
          gamedig = prev.callPackage (import "${inputs.gamedig}/pkgs/by-name/ga/gamedig/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=578307
          mealie = prev.callPackage (import "${inputs.mealie}/pkgs/by-name/me/mealie/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=578946
          netdata = prev.callPackage (import "${inputs.netdata}/pkgs/tools/system/netdata") {
            go = prev.go_1_27;
            buildGoModule = prev.buildGo127Module;
          };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=578257
          onedrive = prev.callPackage (import "${inputs.onedrive}/pkgs/by-name/on/onedrive/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=577581
          tautulli = prev.callPackage (import "${inputs.tautulli}/pkgs/by-name/ta/tautulli/package.nix") { };

          # TODO remove when nixpkgs mcp-nixos builds again, currently fastmcp-slim is broken
          inherit (inputs.mcp-nixos.packages.${prev.stdenv.hostPlatform.system}) mcp-nixos;
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
