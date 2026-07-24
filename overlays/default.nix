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
  })
  (_: prev: {
    wallpaper = prev.callPackage ./wallpaper { };
  })
]
