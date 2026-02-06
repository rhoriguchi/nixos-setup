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

    # TODO remove when hyprland flake input updated, hyprtoolkit>=0.4.1
    hyprpaper = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "d12cf61ec1b2a2e06f7bcb2c54c70a74b5aac6a6";
        sha256 = "sha256-lZEiIXjpDJRax7VTdL5lAkgkHmZ0GvLNCmONy4WjZds=";
      }
    }/pkgs/by-name/hy/hyprpaper/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=450661
    superfile = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "ce389a35cb472c9b8b212f1243ea1cf630ecd9c8";
        sha256 = "sha256-GcK41zt58umMdNJCAOjUiGxlTEiVZtaMG1Gv3aGwmIU=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
    gamedig = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "e20b67922abcee860daa553bc3b86248c2179863";
        sha256 = "sha256-em1mxsHT02vtqIN3Pw1OyuWZ9nJUp2dTrb8ROg1Cspc=";
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

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=484733
    plexRaw = super.python3Packages.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "ddafe6abe1e1836a1cc596010d6d7daa70d36fb5";
        sha256 = "sha256-rwLP4kWOlOIwLzmivOpwdHISls9MVeqAnntBDxlgq0c=";
      }
    }/pkgs/servers/plex/raw.nix") { };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
