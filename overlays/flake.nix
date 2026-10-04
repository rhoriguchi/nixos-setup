{
  description = "Local package overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    gamedig = {
      url = "github:NixOS/nixpkgs/pull/467867/head";
      flake = false;
    };

    flashrom = {
      url = "github:NixOS/nixpkgs/pull/563332/head";
      flake = false;
    };

    sonarr = {
      url = "github:NixOS/nixpkgs/pull/565157/head";
      flake = false;
    };

    netdata = {
      url = "github:NixOS/nixpkgs/pull/569151/head";
      flake = false;
    };

    jellyfin = {
      url = "github:NixOS/nixpkgs/36ad827548eeb6c254289a3d427c17f78a139da7";
      flake = false;
    };

    jellyfin-ffmpeg = {
      url = "github:NixOS/nixpkgs/f0bbf6065ee0779a042acebaa18b361a496af9f9";
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

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=563332
          flashrom = prev.callPackage (import "${inputs.flashrom}/pkgs/by-name/fl/flashrom/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=565157
          sonarr = prev.callPackage (import "${inputs.sonarr}/pkgs/by-name/so/sonarr/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=569151
          netdata = prev.callPackage (import "${inputs.netdata}/pkgs/tools/system/netdata") {
            go = prev.go_1_27;
            buildGoModule = prev.buildGo127Module;
          };
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

        # TODO remove when declarative-jellyfin supports latest version
        (final: _: {
          jellyfin = final.callPackage (import "${inputs.jellyfin}/pkgs/by-name/je/jellyfin/package.nix") { };

          jellyfin-web =
            final.callPackage (import "${inputs.jellyfin}/pkgs/by-name/je/jellyfin-web/package.nix")
              { };

          jellyfin-ffmpeg =
            final.callPackage (import "${inputs.jellyfin-ffmpeg}/pkgs/by-name/je/jellyfin-ffmpeg/package.nix")
              { };
        })

        (_: prev: {
          wallpaper = prev.callPackage ./wallpaper { };
        })
      ];
    };
}
