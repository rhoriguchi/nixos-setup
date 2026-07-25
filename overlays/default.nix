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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=544063
    plexRaw = prev.python3Packages.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "ddec78082ce3c8b288d98d814d3ba6ede5be549e";
        sha256 = "sha256-zjNcynsWxYIfIJBvGImE1fwJeREivcn2iCnJcHLVMaI=";
      }
    }/pkgs/by-name/pl/plexRaw/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=545217
    diffnav = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "08216c07766c42eed496abb445c61e40db5e937b";
        sha256 = "sha256-TAAkhp1m5sJgLP7vUHSp63GfJWUbcG69po8r0NlSXPk=";
      }
    }/pkgs/by-name/di/diffnav/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=545363
    prowlarr = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "9a1f41b1d26a19f1108253a22a79a7d2431384c7";
        sha256 = "sha256-aDMfbDHuQ9sHjV69e9fX1OYSo8CG9IkNI/zLnIk5uTs=";
      }
    }/pkgs/by-name/pr/prowlarr/package.nix") { };

    # TODO remove when https://github.com/NixOS/nixpkgs/issues/544083 resolved
    poetry = prev.poetry.overridePythonAttrs (_: {
      doCheck = false;
    });
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
