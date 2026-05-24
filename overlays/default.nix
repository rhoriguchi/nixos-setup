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

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=521410
    nwg-displays = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "c3ecc9e9250f26f21b1e42ab38efd72c166feb9e";
        sha256 = "sha256-l7P5VVA0rvTKIUOuA+vg5penE3nmlbPYyPAPnAjzaLs=";
      }
    }/pkgs/by-name/nw/nwg-displays/package.nix") { };
  })
  # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=522705
  (final: prev: {
    python3 = prev.python3.override {
      packageOverrides = _: _: {
        jedi-language-server = prev.python3Packages.callPackage (import "${
          prev.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "b07305823393e93af763459ad78072eb6b60588c";
            sha256 = "sha256-K0zLTJFI6sfsx2V/5pEKwwkxEGFYPmP6NWx5x8p22is=";
          }
        }/pkgs/development/python-modules/jedi-language-server") { };
      };
    };

    python3Packages = final.python3.pkgs;
  })
  (_: prev: {
    hs = prev.callPackage ./hs { };

    wallpaper = prev.callPackage ./wallpaper { };
  })
]
