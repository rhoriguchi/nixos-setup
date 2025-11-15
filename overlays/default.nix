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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=461052
    adguardhome = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "c870ad4862046e20d63947bad6bf3eb4450d6aac";
        sha256 = "sha256-CGSmZ08yEEhNUoUNEyrEVs4CRI0aL6wIta6QaJBpWj8=";
      }
    }/pkgs/by-name/ad/adguardhome/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=461661
    rustdesk-flutter = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "45667c9df233b49115c7aca6bd8c68b2a46a6037";
        sha256 = "sha256-HSM1nF/URWYRyn98Z2i0RhsHH88DFecLep8k6J4ZV7A=";
      }
    }/pkgs/by-name/ru/rustdesk-flutter/package.nix") { };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
