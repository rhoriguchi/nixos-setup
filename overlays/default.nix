[
  (_: prev: {
    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=450661
    superfile = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "8bb3076ef969c704ab8eb4acef2362337d55a0e7";
        sha256 = "sha256-UtTOiPZ32o7Xmy0byCRkrt4taBnc0O/F3LG50PsTJA0=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
    gamedig = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "f51a8cbcfca0c5668c0c95b98b5a5921a8e88776";
        sha256 = "sha256-XyfwZpc79a+uqKx41bzCvK0UKJWlGkYqtqhAKPZbDus=";
      }
    }/pkgs/by-name/ga/gamedig/package.nix") { };

    # TODO remove when merged https://github.com/NixOS/nixpkgs/pull/563332
    flashrom = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "45cad503a7a0873ff8fa0542d749b495631808b0";
        sha256 = "sha256-kXAWCXGTwQsxMqm2OGyXjmBDAqCLZbcKZbiLKuMWzm4=";
      }
    }/pkgs/by-name/fl/flashrom/package.nix") { };

    # TODO remove when merged https://github.com/NixOS/nixpkgs/pull/565157
    sonarr = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "92270594a141f6724f72ccd064ec6e4b68623d53";
        sha256 = "sha256-De+vX+S3YXMDgGAmpRL4+elIjMUU5SWzh46HGo94uEE=";
      }
    }/pkgs/by-name/so/sonarr/package.nix") { };
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
  (
    final: prev:
    let
      src = prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "36ad827548eeb6c254289a3d427c17f78a139da7";
        sha256 = "sha256-AN+Jdi2y1yI6FRp6bFcWV2VAdlgJdehAmLSouxsreHA=";
      };
    in
    {
      jellyfin = final.callPackage (import "${src}/pkgs/by-name/je/jellyfin/package.nix") { };

      jellyfin-web = final.callPackage (import "${src}/pkgs/by-name/je/jellyfin-web/package.nix") { };

      jellyfin-ffmpeg = final.callPackage (import "${
        prev.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "f0bbf6065ee0779a042acebaa18b361a496af9f9";
          sha256 = "sha256-jY5K98BLpTMkqoMAcqa8hRwkyYmC7zd+wV1k5PPrXsk=";
        }
      }/pkgs/by-name/je/jellyfin-ffmpeg/package.nix") { };
    }
  )

  (_: prev: {
    wallpaper = prev.callPackage ./wallpaper { };
  })
]
