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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=446721
    netdata = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "bd25e53de06dc2433a640176e141b84751d3d4e6";
        sha256 = "sha256-8eE0tCtND6LAw2H3uHw7eN0iXaSj4Ccyp2FGxeSZtPs=";
      }
    }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=450661
    superfile = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "ca65ed64dc813ba6e23c2d4cb9555fbdfa13aa3e";
        sha256 = "sha256-i0PoR19YmstJwWMKTh9Opl8Qc4rp1qmo7m/9BkbUkEs=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=463572
    prowlarr = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "5086f942982795e91c9dd0329cdc5fd9153815ec";
        sha256 = "sha256-42AD1+O8eL1GkzIz8OHXqAVWIfMLuQgLUSB42s8Cdgk=";
      }
    }/pkgs/by-name/pr/prowlarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=463588
    sonarr = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "e9a6f320c08199693a03a00662141897cd3c79ce";
        sha256 = "sha256-H9J75I57PF1Xig5YiUmewqAu8ZfejtVcCkCdOTnl4l0=";
      }
    }/pkgs/by-name/so/sonarr/package.nix") { };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
