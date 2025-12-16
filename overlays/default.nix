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
        rev = "ca65ed64dc813ba6e23c2d4cb9555fbdfa13aa3e";
        sha256 = "sha256-i0PoR19YmstJwWMKTh9Opl8Qc4rp1qmo7m/9BkbUkEs=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=463836
    netdata = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "96fe96a74d207796405c9a7c8bdde4fc1eedf07f";
        sha256 = "sha256-17JTdcoOJykWZ4C90rrc75JiDATGmEbOuA68MzV/LTg=";
      }
    }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
    gamedig = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "a9a8147413724d446546de0df52e33732351213e";
        sha256 = "sha256-CY0Liw7AnigI8Ca/KHj1Ya6u15eZOtMz1wRDFdekRAw=";
      }
    }/pkgs/by-name/ga/gamedig/package.nix") { };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
