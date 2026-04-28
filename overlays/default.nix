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
        rev = "96a1de845c46bff135a97ea91ce9508e9fd78e7a";
        sha256 = "sha256-gzVMiypK0iuJeAG96AMrKlbQA/8KyzJxrrUDo56xCoU=";
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
  })
  (_: prev: {
    hs = prev.callPackage ./hs { };

    wallpaper = prev.callPackage ./wallpaper { };
  })
  # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=513680
  (final: prev: {
    python3 = prev.python3.override {
      packageOverrides = _: _: {
        aioboto3 = prev.python3Packages.callPackage (import "${
          prev.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "bba77e69fc1642c39698af393c4e379cfe26cf8e";
            sha256 = "sha256-uUZKxM2uzrvOKMHIShfv3zJXeS0uTIeuYPkqXJaogUQ=";
          }
        }/pkgs/development/python-modules/aioboto3/default.nix") { };
      };
    };

    python3Packages = final.python3.pkgs;
  })
]
