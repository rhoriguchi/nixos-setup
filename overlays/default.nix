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

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=530124
    prowlarr = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "4d11dd63488e76280445544e9e3b8f39a0aa2e71";
        sha256 = "sha256-je59cSRtfoz2H34zOlLJd/PLuyRNEPxyBM6NWZx/yTE=";
      }
    }/pkgs/by-name/pr/prowlarr/package.nix") { };
  })
  (_: prev: {
    hs = prev.callPackage ./hs { };

    wallpaper = prev.callPackage ./wallpaper { };
  })
]
