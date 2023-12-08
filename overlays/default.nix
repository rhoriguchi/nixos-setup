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

    gnomeExtensions = super.gnomeExtensions // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=270321
      unite = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "3851d20b7586c26979da0da05ea57235fa989a42";
            hash = "sha256-b05dOc/5RFmXEPlkaYzy7EvSmaPJ5FNWY84/Snv1Rdw=";
          }
        }/pkgs/desktops/gnome/extensions/unite") { };
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=272722
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "8d06988a1a76f17d7f9df9a81c3a32f04550990e";
          sha256 = "sha256-z+1bm/Qs3WQTlz50ZD0L5GxxhFQJnYqotfHFF2EXtag=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=273019
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "1392efba795617a3e1d6b34abea71f33fd762ade";
          sha256 = "sha256-CNf/tJ5OO37sevha7xpMJVeI+iG7Ww7kwis9en0xkos=";
        }
      }/pkgs/servers/plex/raw.nix") { };
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
