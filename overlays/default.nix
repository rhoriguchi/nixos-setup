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
  })
  (_: prev: {
    hs = prev.callPackage ./hs { };

    wallpaper = prev.callPackage ./wallpaper { };
  })
]
