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

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=534753
    home-assistant-custom-lovelace-modules = prev.home-assistant-custom-lovelace-modules // {
      fold-entity-row = prev.callPackage (import "${
        prev.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "0b4b6c94046ab86615c4b3a8131e1effe6b1ad2c";
          sha256 = "sha256-O5ZamRhr2jtUG+iUdD9B9PDnosCkg88MiCqeCviY36M=";
        }
      }/pkgs/servers/home-assistant/custom-lovelace-modules/fold-entity-row/package.nix") { };
    };
  })
  (_: prev: {
    wallpaper = prev.callPackage ./wallpaper { };
  })
]
