[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e153ea34065a3c9108c8878a7d57a5d148ca7f19";
          sha256 = "sha256-LmZbmbuYt6SOclXj7VkEMzRQQsObyZYj/nx10AT55BM=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=186139
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "509541c7a735db6346da0f75eda9e7870c078ecc";
          sha256 = "sha256-bfVTqsKII0DaewAUwnGnG8m4cfP+g8Sa4aDZr5myJXg=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=189875
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4a77588c79aef32fa10cbecb77c7bad122f068e8";
          sha256 = "sha256-jDM7KM1RP81Y4qkONM9wcNN8/1vr3zXM9ylr8H1O4QA==";
        }
      }/pkgs/servers/plex/raw.nix") { };
  })
  (self: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
