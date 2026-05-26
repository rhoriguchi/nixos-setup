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

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=521410
    nwg-displays = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "c3ecc9e9250f26f21b1e42ab38efd72c166feb9e";
        sha256 = "sha256-l7P5VVA0rvTKIUOuA+vg5penE3nmlbPYyPAPnAjzaLs=";
      }
    }/pkgs/by-name/nw/nwg-displays/package.nix") { };

    linuxPackages_latest = prev.linuxPackages_latest.extend (
      _: kernelPrev: {
        # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=523308
        openrazer = kernelPrev.callPackage (import "${
          prev.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "99643def59501d1eabb1ca01ef701b66d41908fe";
            sha256 = "sha256-GGsXHdmXIlI8q0qDYkelWsquTDhYzSAVmfWrwEoF73w=";
          }
        }/pkgs/os-specific/linux/openrazer/driver.nix") { };
      }
    );
  })
  (_: prev: {
    hs = prev.callPackage ./hs { };

    wallpaper = prev.callPackage ./wallpaper { };
  })
]
