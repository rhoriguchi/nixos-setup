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

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=555912
    scanservjs = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "a68173d41f22d36fc9f4125e862993d6f0b8a2c3";
        sha256 = "sha256-i2+wEfzVL7hueFZHnM9ePB4WX2VW4wMybbpyY9pVjkk=";
      }
    }/pkgs/by-name/sc/scanservjs/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=557709
    tautulli = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "47b032747c3efa00dcbb50704465d095241abcd5";
        sha256 = "sha256-OhrsaGD2f0FUHMr3hAqBHSI+e66ecLHSYPxqQ1c9d8Y=";
      }
    }/pkgs/by-name/ta/tautulli/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=557748
    bazecor = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "5dd04ae305069934a9eaf69a073d22cbede6cd1c";
        hash = "sha256-DAlya5cHhGaTn6pyG2g+bsuYcERWkXt8GcWXgVVMISg=";
      }
    }/pkgs/by-name/ba/bazecor/package.nix") { };
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
]
