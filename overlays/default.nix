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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=265227
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "c6ce4bc05172e47b36b5c4a4e410834f9c91b904";
          hash = "sha256-sU2juheULfXZxGVQC6UFwaA2mE6zul0DCQp+AssbyHY=";
        }
      }/pkgs/servers/plex/raw.nix") { };

    nodePackages = super.nodePackages // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=267127
      showdown = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "731aa7f177991e992a15367fd32cb0a536dfec4b";
            hash = "sha256-pP+eZ1wXfsycfgnHajuvPssDCFbo0obPihl5BIpXuJ4=";
          }
        }/pkgs/tools/text/showdown") { };
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
