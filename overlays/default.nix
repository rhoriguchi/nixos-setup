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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=390165
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "558331c869ba8b2c8989a52c81d25f4f4070047c";
          sha256 = "sha256-xiF/2bpsZpsPKEBW8e7j0NzRb8TSgmEdkSQeSL4nbAg=";
        }
      }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=391400
    sonarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "de5d17112156bf80bb0f3870167c8a9f5268ebeb";
          sha256 = "sha256-e2ljR1cZY3WjAr2O0QBEMRCbxHk/qnrhzHhvNOCGDII=";
        }
      }/pkgs/by-name/so/sonarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=393335
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "c850d1c436fd584b91093b6c4be1897192a2d2b4";
          sha256 = "sha256-5NX6MgonkLabTyumi2+pshlbY24QNUEkOZfFf9fLvrk=";
        }
      }/pkgs/by-name/pr/prowlarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=393454
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "b563d1ebe1342f6ade1e48f23f63817b01f9fbff";
          sha256 = "sha256-0bGBCjWyfyNe17nhnzZC+TL7Wog2GrnBjifZK77p2v0=";
        }
      }/pkgs/servers/adguardhome") { };
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
