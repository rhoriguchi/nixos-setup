[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e153ea34065a3c9108c8878a7d57a5d148ca7f19";
          sha256 = "sha256-LmZbmbuYt6SOclXj7VkEMzRQQsObyZYj/nx10AT55BM=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=196971
    gnomeExtensions = super.gnomeExtensions // {
      dash-to-dock = super.gnomeExtensions.dash-to-dock.overrideAttrs (_: rec {
        version = "75";

        src = super.fetchFromGitHub {
          owner = "micheleg";
          repo = "dash-to-dock";
          rev = "extensions.gnome.org-v${version}";
          sha256 = "sha256-vHXNhJgty7x4Ef6jxUI29KYpadC3jtUqE1Nt1dWYr24=";
        };
      });
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=196978
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "a50504c96a070c3ceb845967533c626e0622089d";
          sha256 = "sha256-IfcNw8TgqhxBVfRDm/lqGxUIi3rFhF4rtkkR+7+S+Dw=";
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

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
