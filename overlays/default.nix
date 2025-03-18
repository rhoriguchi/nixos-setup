[
  (_: super: {
    gnomeExtensions = super.gnomeExtensions // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=385948
      unite = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "a7c108c44e8ae878e6dec01563e79381ea6a446f";
            hash = "sha256-2H3KyY2mw969VCLZOXwMOyhNZbtS1vSSCxSxbrGaYe8=";
          }
        }/pkgs/desktops/gnome/extensions/unite/default.nix") { };
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=389378
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e69a001b66b91ef0b0875738ec00270747051f45";
          sha256 = "sha256-Tt0oUrTZSXHtHz8T5vxNjA8sn/dbLEeQzyjUIAb2GDE=";
        }
      }/pkgs/servers/plex/raw.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=390165
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "558331c869ba8b2c8989a52c81d25f4f4070047c";
          sha256 = "sha256-xiF/2bpsZpsPKEBW8e7j0NzRb8TSgmEdkSQeSL4nbAg=";
        }
      }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    hs = super.callPackage ./hs { };
  })
]
