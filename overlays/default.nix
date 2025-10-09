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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=449677
    borgmatic = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "95ead6d497513f80646da927d1d86390ade713ed";
        sha256 = "sha256-cYswH0Cs+1HVj/KWnTLmDTB4A1t18rcs+yD5N6QWJLA=";
      }
    }/pkgs/by-name/bo/borgmatic/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=448946
    brlaser = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "c9c2a2f91687c76a9deabb168c18d16612c68432";
        sha256 = "sha256-jlx0xGYCEgTunCH4wH3KDIKdmujSKPfLSGQ38BGO3O4=";
      }
    }/pkgs/by-name/br/brlaser/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=449133
    intel-graphics-compiler = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "ac194b0e0dd1ad78620bb77c31c6ca54b6ef8caf";
        sha256 = "sha256-uYoWkJDyKTKoTcCDwMhiHiwjygidMM7kkG+o3i9pKZ0=";
      }
    }/pkgs/by-name/in/intel-graphics-compiler/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=449772
    libraspberrypi = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "fe9c50a981240746b37b1d2966b4c06576278ee0";
        sha256 = "sha256-staO0aKIMTLVbNdqdqqN8BM7JJSXCc0qeoOTpO7fPGg=";
      }
    }/pkgs/by-name/li/libraspberrypi/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=450064
    rtrlib = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "2dca904c1d47a06ae19a9dcfdb74c8e0e599c523";
        sha256 = "sha256-xsQ0fDEuA7/nAf1mjEQiHv7KJgh8iDdV+D/4n7Kb6z0=";
      }
    }/pkgs/by-name/rt/rtrlib/package.nix") { };
  })
  (_: super: { hs = super.callPackage ./hs { }; })
]
