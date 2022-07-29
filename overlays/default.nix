[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=181856
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e12aa0bb9e0d9392cb9d6158e2cea36611bb38a8";
          sha256 = "sha256-6AicdbFzWft4c6rCjm2XJ8KCvrnZM0/lGi8csFoSN7w=";
        }
      }/pkgs/applications/version-management/gitkraken") { };
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
