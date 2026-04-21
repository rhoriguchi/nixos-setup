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
        rev = "905e73f3e7fc9d96b106cbb2dea3cda885226971";
        sha256 = "sha256-42rStReeeU2KSQ+FWmH44qr886PnATbiUVtXjFJTbcE=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
    gamedig = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "96a1de845c46bff135a97ea91ce9508e9fd78e7a";
        sha256 = "sha256-gzVMiypK0iuJeAG96AMrKlbQA/8KyzJxrrUDo56xCoU=";
      }
    }/pkgs/by-name/ga/gamedig/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=508784
    netdata = super.callPackage (import "${
      super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "2a682cc0cafc12542fee6a79a1dd7f32005feac5";
        sha256 = "sha256-iNSn5p2XwIL2dkP1uV/xxIHcmIiVThoNSAkKKpFiDOc=";
      }
    }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };
  })
  (_: super: {
    hs = super.callPackage ./hs { };

    wallpaper = super.callPackage ./wallpaper { };
  })
]
