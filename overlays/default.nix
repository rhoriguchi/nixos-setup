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

  # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=545582
  (
    final: prev:
    let
      src = prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "2445a70b06cb20bb734e268052b485bdd21e5e45";
        sha256 = "sha256-qbHvii3aQwvmw278rvmv2vF7AtxWYGRY3R2dAX6JUL0=";
      };
    in
    {
      netdata = prev.callPackage (import "${src}/pkgs/tools/system/netdata") { };

      python3 = prev.python3.override {
        packageOverrides = _: _: {
          netdata-pandas =
            prev.python3Packages.callPackage
              (import "${src}/pkgs/development/python-modules/netdata-pandas/default.nix")
              { };
        };
      };

      python3Packages = final.python3.pkgs;
    }
  )

  (_: prev: {
    wallpaper = prev.callPackage ./wallpaper { };
  })
]
