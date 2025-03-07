[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=384063
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "cdd76d7b261945b2d05f13e850386931a0244005";
          sha256 = "sha256-jmXsnbePZastvuEW5GBFxLNoH7NuPDHDI17U2/vUctg=";
        }
      }/pkgs/servers/plex/raw.nix") { };

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

    home-assistant-custom-components = super.home-assistant-custom-components // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=387487
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "06f80f51080e9f5636ac63c6c0cad13e462bb83e";
            sha256 = "sha256-koxE7NH/i2niL3rHv9rSoIPXs20hWcxBmHh/WiZ+0hg=";
          }
        }/pkgs/servers/home-assistant/custom-components/localtuya/package.nix") { };
    };
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
