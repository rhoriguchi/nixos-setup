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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=445527
    plexRaw = super.python3Packages.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "01374ab240719dab48d2eec7bab357c3f5b17cef";
        sha256 = "sha256-cN8LdLctC59z/dzvqUlCCNIriRlfVw96mcSPR90ELXI=";
      }
    }/pkgs/servers/plex/raw.nix") { };

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
  })
  (_: super: { hs = super.callPackage ./hs { }; })
]
