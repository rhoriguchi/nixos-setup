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
          rev = "3a236d83c9aee844a869ac3d6e8117012d000de3";
          sha256 = "sha256-uBh6bWdmxq24COCY5PdLhCFSrL7f/Ozi6F/JbBBy/Qw=";
        }
      }/pkgs/servers/prowlarr") { };

    home-assistant-custom-components = super.home-assistant-custom-components // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=285149
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "439cbb3721b06db26935e62aac190cbbdf481fd8";
            sha256 = "sha256-ni+YZImDYtRIlj5a0CFlP7WMVixtKzuDlDq7ReImk2s=";
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
