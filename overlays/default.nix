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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=333966
    bazecor = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "f190f6e4881546c6c07ecad8d27b34328fbee988";
          hash = "sha256-b4eMtWeRkO5K4geEHyRNZcTdDFNpVLNRfXyKYbo8ty4=";
        }
      }/pkgs/by-name/ba/bazecor/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=334020
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "a7f6a89fc067551f2d6f752dd7c540e3680020cd";
          sha256 = "sha256-Yj5h67bN4TC+PTTs///5pBniIspJn5EaYTas7io3fWU=";
        }
      }/pkgs/servers/prowlarr") { };

    home-assistant-custom-components = super.home-assistant-custom-components // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=337980
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "060ad743acf87c6d330d86ae9df433a90f60ad94";
            sha256 = "sha256-qqJX2fJbRTp6Ur1fJcFveenTxP6INseo8Ckhxfq7pxM=";
          }
        }/pkgs/servers/home-assistant/custom-components/localtuya") { };
    };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };
  })
]
