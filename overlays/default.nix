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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=446779
    onedrive = super.python3Packages.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "b1ce8d19eabffd8b2ca466a631850f605f5736a2";
        sha256 = "sha256-fKimQxk9aReZSS8KufLpR+f/mWDOmcjQ7MwLmGwLVsY=";
      }
    }/pkgs/by-name/on/onedrive/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=449677
    borgmatic = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "95ead6d497513f80646da927d1d86390ade713ed";
        sha256 = "sha256-cYswH0Cs+1HVj/KWnTLmDTB4A1t18rcs+yD5N6QWJLA=";
      }
    }/pkgs/by-name/bo/borgmatic/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=449772
    libraspberrypi = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "fe9c50a981240746b37b1d2966b4c06576278ee0";
        sha256 = "sha256-staO0aKIMTLVbNdqdqqN8BM7JJSXCc0qeoOTpO7fPGg=";
      }
    }/pkgs/by-name/li/libraspberrypi/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=450661
    superfile = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "7191882b004e3d572286737f1afc1e0c783997c5";
        sha256 = "sha256-reDPwf05bbh0NGCeAy3bGRuIDoINMdpJB4BZy3q+Imw=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };
  })
  (_: super: { hs = super.callPackage ./hs { }; })
]
