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

    nginx = {
      url = "github:NixOS/nixpkgs/pull/589961/head";
      flake = false;
    };

    servarr = {
      url = "github:NixOS/nixpkgs/pull/589560/head";
      flake = false;
    };

    tautulli = {
      url = "github:NixOS/nixpkgs/pull/589632/head";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      overlays.default = nixpkgs.lib.composeManyExtensions [
        (
          _: prev:
          let
            openur-ffmpeg =
              prev.callPackage (import "${inputs.servarr}/pkgs/by-name/op/openur-ffmpeg/package.nix")
                { };
          in
          {
            # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=585101
            adguardhome =
              prev.callPackage (import "${inputs.adguardhome}/pkgs/by-name/ad/adguardhome/package.nix")
                { buildGoModule = prev.buildGo127Module; };

            # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
            gamedig = prev.callPackage (import "${inputs.gamedig}/pkgs/by-name/ga/gamedig/package.nix") { };

            # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=589961
            nginxStable = prev.callPackage (import "${inputs.nginx}/pkgs/servers/http/nginx/stable.nix") {
              openssl = prev.openssl_4_1;
              zlib-ng = prev.zlib-ng.override { withZlibCompat = true; };
              withPerl = false;
              modules = [ prev.nginxModules.moreheaders ];
            };

            # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=589560
            prowlarr = prev.callPackage (import "${inputs.servarr}/pkgs/by-name/pr/prowlarr/package.nix") { };

            # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=589560
            radarr = prev.callPackage (import "${inputs.servarr}/pkgs/by-name/ra/radarr/package.nix") {
              inherit openur-ffmpeg;
            };

            # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=589560
            sonarr = prev.callPackage (import "${inputs.servarr}/pkgs/by-name/so/sonarr/package.nix") {
              inherit openur-ffmpeg;
            };

            # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=589632
            tautulli = prev.callPackage (import "${inputs.tautulli}/pkgs/by-name/ta/tautulli/package.nix") { };
          }
        )

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
