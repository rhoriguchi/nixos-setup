[
  (_: prev: {
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
        rev = "0316d482c5909f83e7653bd00f8891ae42359671";
        sha256 = "sha256-/lu7YeE20O/RtToa1J3NFFeSIgXqqe9OE2hNiHH76WI=";
      }
    }/pkgs/tools/system/netdata") { protobuf = prev.protobuf_21; };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=517801
    tautulli = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "7ef4e3393f0cc887cb15d1d1a62a921ee5f2f870";
        sha256 = "sha256-5+9j8WuZj1wkmtZ7xuo43fpd8OLaEEdl8bF1g8NN2Vs=";
      }
    }/pkgs/by-name/ta/tautulli/package.nix") { };
  })
  (_: prev: {
    hs = prev.callPackage ./hs { };

    wallpaper = prev.callPackage ./wallpaper { };
  })
]
