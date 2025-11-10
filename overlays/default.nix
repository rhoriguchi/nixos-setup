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
        rev = "47e7b056b71dd443dd211840f8af46beea7a904b";
        sha256 = "sha256-uOzE3AridjAJkn9xRiWBNu89JJuKlEVAVvNVehPnL10=";
      }
    }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=450661
    superfile = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "7191882b004e3d572286737f1afc1e0c783997c5";
        sha256 = "sha256-reDPwf05bbh0NGCeAy3bGRuIDoINMdpJB4BZy3q+Imw=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=454342
    adguardhome = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "dade0b2ef49e2815c81ef241bee40df45b157437";
        sha256 = "sha256-+VNeNOVFpxu5l32BYQPqcY95+/PMjiHsWKpIG3kP2+8=";
      }
    }/pkgs/by-name/ad/adguardhome/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=459938
    tmuxp = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "8d2e2814cf205cea94c043a220c905bc336d026e";
        sha256 = "sha256-U9wvdGAO+folG/zuzYxR1kG/8x4UUiDaxKYoNDpx0iU=";
      }
    }/pkgs/by-name/tm/tmuxp/package.nix") { };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
