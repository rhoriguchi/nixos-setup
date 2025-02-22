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

    home-assistant-custom-components = super.home-assistant-custom-components // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=383209
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "0aaa430cbe4509bbe176777cf0ce289e5b04c6e5";
            sha256 = "sha256-3nEKtG7o3oVYaWrnytzdsPV8ZvZp/PpElQkIgumreCM=";
          }
        }/pkgs/servers/home-assistant/custom-components/localtuya/package.nix") { };
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=384063
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "cdd76d7b261945b2d05f13e850386931a0244005";
          sha256 = "sha256-jmXsnbePZastvuEW5GBFxLNoH7NuPDHDI17U2/vUctg=";
        }
      }/pkgs/servers/plex/raw.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=367595
    resilio-sync = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "b452638f9063ab8c3b75eceb8b1519ba33b69dbe";
          sha256 = "sha256-PFZky+zudwHt02Ulp2XHJB5JVFk2fYYMIwKLiv37rzE=";
        }
      }/pkgs/by-name/re/resilio-sync/package.nix") { };
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
