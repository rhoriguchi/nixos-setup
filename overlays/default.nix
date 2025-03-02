[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4fd5da3781ed6d12a139bee1c84d17772edf130c";
          hash = "sha256-VlvxAWOKZ/ih7bxKxD2qfp2S8skGABS90hfmP8aV2w0=";
        }
      }/pkgs/tools/system/fancy-motd") { };

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
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=386405
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "c8364760c7388f99cda01b195ac2d3f7ae9398f6";
            sha256 = "sha256-kDGlobhlPxPyn+stH6eVoNP3hJMyhDQ89IIwiAKnF8Y=";
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
