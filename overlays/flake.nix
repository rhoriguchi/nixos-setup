{
  description = "Local package overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    adguardhome = {
      url = "github:NixOS/nixpkgs/pull/585101/head";
      flake = false;
    };

    gamedig = {
      url = "github:NixOS/nixpkgs/pull/467867/head";
      flake = false;
    };

    jellyfin = {
      url = "github:NixOS/nixpkgs/bf316c9c2a7763dfae6171b3e1622401831ddfec";
      flake = false;
    };

    netdata = {
      url = "github:NixOS/nixpkgs/pull/585482/head";
      flake = false;
    };

    nwg-drawer = {
      url = "github:NixOS/nixpkgs/pull/585260/head";
      flake = false;
    };

    openlogi = {
      url = "github:NixOS/nixpkgs/pull/583471/head";
      flake = false;
    };

    prowlarr = {
      url = "github:NixOS/nixpkgs/pull/581969/head";
      flake = false;
    };

    "python3Packages.geopandas" = {
      url = "github:NixOS/nixpkgs/pull/584702/head";
      flake = false;
    };

    "python3Packages.speechrecognition" = {
      url = "github:NixOS/nixpkgs/pull/585193/head";
      flake = false;
    };

    rustdesk-flutter = {
      url = "github:NixOS/nixpkgs/pull/585583/head";
      flake = false;
    };

    waybar = {
      url = "github:NixOS/nixpkgs/pull/583754/head";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      overlays.default = nixpkgs.lib.composeManyExtensions [
        (_: prev: {
          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=585101
          adguardhome =
            prev.callPackage (import "${inputs.adguardhome}/pkgs/by-name/ad/adguardhome/package.nix")
              { buildGoModule = prev.buildGo127Module; };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
          gamedig = prev.callPackage (import "${inputs.gamedig}/pkgs/by-name/ga/gamedig/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=585482
          netdata = prev.callPackage (import "${inputs.netdata}/pkgs/tools/system/netdata/default.nix") {
            buildGoModule = prev.buildGo127Module;
            go = prev.go_1_27;
          };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=585260
          nwg-drawer =
            prev.callPackage (import "${inputs.nwg-drawer}/pkgs/by-name/nw/nwg-drawer/package.nix")
              { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=583471
          openlogi = prev.callPackage (import "${inputs.openlogi}/pkgs/by-name/op/openlogi/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=581969
          prowlarr = prev.callPackage (import "${inputs.prowlarr}/pkgs/by-name/pr/prowlarr/package.nix") { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=585583
          rustdesk-flutter =
            prev.callPackage (import "${inputs.rustdesk-flutter}/pkgs/by-name/ru/rustdesk-flutter/package.nix")
              { };

          # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=583754
          waybar = prev.callPackage (import "${inputs.waybar}/pkgs/by-name/wa/waybar/package.nix") { };
        })

        (_: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (pythonFinal: _: {
              # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=584702
              geodatasets = pythonFinal.callPackage "${
                inputs."python3Packages.geopandas"
              }/pkgs/development/python-modules/geodatasets/default.nix" { };

              # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=584702
              geopandas = pythonFinal.callPackage "${
                inputs."python3Packages.geopandas"
              }/pkgs/development/python-modules/geopandas/default.nix" { };

              # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=585193
              speechrecognition = pythonFinal.callPackage "${
                inputs."python3Packages.speechrecognition"
              }/pkgs/development/python-modules/speechrecognition/default.nix" { };
            })
          ];
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
            final.callPackage (import "${inputs.jellyfin}/pkgs/by-name/je/jellyfin-ffmpeg/package.nix")
              { };
        })

        (_: prev: {
          wallpaper = prev.callPackage ./wallpaper { };
        })
      ];
    };
}
