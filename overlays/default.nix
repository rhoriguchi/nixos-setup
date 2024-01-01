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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=278091
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "c816b8e71e946917bb107bee8a3064e516a382b1";
          sha256 = "sha256-fUoKydExITA/HnfrxJnm6Qukmub9LdcIhNWtvMjO+xw=";
        }
      }/pkgs/servers/prowlarr") { };
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
