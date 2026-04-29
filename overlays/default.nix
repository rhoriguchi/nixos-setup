[
  (_: prev: {
    # Resilio Sync 3.0.2.1058 will break after a while
    resilio-sync = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "4f0dadbf38ee4cf4cc38cbc232b7708fddf965bc";
        sha256 = "sha256-jQNGd1Kmey15jq5U36m8pG+lVsxSJlDj1bJ167BjHQ4=";
      }
    }/pkgs/by-name/re/resilio-sync/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=450661
    superfile = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "905e73f3e7fc9d96b106cbb2dea3cda885226971";
        sha256 = "sha256-42rStReeeU2KSQ+FWmH44qr886PnATbiUVtXjFJTbcE=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
    gamedig = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "59a2bb07bfe264a8e3efdbae7d3037f3915c8571";
        sha256 = "sha256-7LbhWgR0PN9y4Of0HxkxAoM5Oq432KpQf8UQiEjj48k=";
      }
    }/pkgs/by-name/ga/gamedig/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=508784
    netdata = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "98bc594e01ccbca10466c2d75a3d38853e50ba3d";
        sha256 = "sha256-llS74fkC0blHLRV0qPxu8REuXt2RRs4GDViq0QAjcXs=";
      }
    }/pkgs/tools/system/netdata") { protobuf = prev.protobuf_21; };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=514808
    adguardhome = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "8d494c49cf5984885a1862b0613d1e10671c55e5";
        sha256 = "sha256-0AlEY6cTm9HoszLpMr7sNI8WvN9e56r2KESMNIXQpus=";
      }
    }/pkgs/by-name/ad/adguardhome/package.nix") { };
  })
  (_: prev: {
    hs = prev.callPackage ./hs { };

    wallpaper = prev.callPackage ./wallpaper { };
  })
]
