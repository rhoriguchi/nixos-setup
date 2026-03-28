[
  (_: super: {
    # Resilio Sync 3.0.2.1058 will break after a while
    resilio-sync = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "4f0dadbf38ee4cf4cc38cbc232b7708fddf965bc";
        sha256 = "sha256-jQNGd1Kmey15jq5U36m8pG+lVsxSJlDj1bJ167BjHQ4=";
      }
    }/pkgs/by-name/re/resilio-sync/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=450661
    superfile = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "905e73f3e7fc9d96b106cbb2dea3cda885226971";
        sha256 = "sha256-42rStReeeU2KSQ+FWmH44qr886PnATbiUVtXjFJTbcE=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
    gamedig = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "291e9536cde499e7f08b23ab2e5ca909b7dec406";
        sha256 = "sha256-xBIxmaqc1lGgX8BTbjtGSu8pCENK+oR9gPm7rEHEGrA=";
      }
    }/pkgs/by-name/ga/gamedig/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=480880
    borgmatic = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "28a66fd11cafbbb4508f6240b9ed02bae7b7fa36";
        sha256 = "sha256-h05YUEmeppFJsw7210gxHIDm0Adv5UTGQtv+V5tMDto=";
      }
    }/pkgs/by-name/bo/borgmatic/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=501809
    sonarr = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "265d204da2c6616afd5356c935779004b5625d7b";
        sha256 = "sha256-6966MIYqP/363jEQ6r4/GE9i8ruv0R3A4wf9b9HURu4=";
      }
    }/pkgs/by-name/so/sonarr/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=504386
    tautulli = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "7e77fe418b1c54522f07fbeff0b0b37a274f80f9";
        sha256 = "sha256-MaP3+Z9t8MSp2ftxiIAbssH1xkS03qQ9gRTkK0YDcfU=";
      }
    }/pkgs/by-name/ta/tautulli/package.nix") { };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
