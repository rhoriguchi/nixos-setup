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
        rev = "260fa1eda21617509fd2696881efce5960e37a3c";
        sha256 = "sha256-9Tmbbk8MbdcIcWUXBRyskxAOANCQ/sbXKnQRl2AtQcM=";
      }
    }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=449677
    borgmatic = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "95ead6d497513f80646da927d1d86390ade713ed";
        sha256 = "sha256-cYswH0Cs+1HVj/KWnTLmDTB4A1t18rcs+yD5N6QWJLA=";
      }
    }/pkgs/by-name/bo/borgmatic/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=450661
    superfile = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "7191882b004e3d572286737f1afc1e0c783997c5";
        sha256 = "sha256-reDPwf05bbh0NGCeAy3bGRuIDoINMdpJB4BZy3q+Imw=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=455217
    onedrive = super.python3Packages.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "514f43f77c269e4476e19acd1b0b32bde13f9b35";
        sha256 = "sha256-BwXAufAeXfPaoo7UxJaxpz8ng1/O9EdWup8ukrkfprA=";
      }
    }/pkgs/by-name/on/onedrive/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=454342
    adguardhome = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "dade0b2ef49e2815c81ef241bee40df45b157437";
        sha256 = "sha256-+VNeNOVFpxu5l32BYQPqcY95+/PMjiHsWKpIG3kP2+8=";
      }
    }/pkgs/by-name/ad/adguardhome/package.nix") { };
  })
  (_: super: { hs = super.callPackage ./hs { }; })
]
