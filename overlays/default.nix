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

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=463572
    prowlarr = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "5086f942982795e91c9dd0329cdc5fd9153815ec";
        sha256 = "sha256-42AD1+O8eL1GkzIz8OHXqAVWIfMLuQgLUSB42s8Cdgk=";
      }
    }/pkgs/by-name/pr/prowlarr/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=463836
    netdata = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "826678640e381d5676886700688de2223844fe88";
        sha256 = "sha256-GMMbhVzJ6+Kw7jHbTz/6ItMXH5Ej13M5hMAQRuFuR5A=";
      }
    }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
