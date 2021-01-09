[
  (self: super: {
    mach-nix = super.callPackage ./mach-nix.nix { pkgs = super; };
  })
  (self: super: {
    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };
    glances = super.callPackage ./glances.nix { inherit (super) glances; };
    gnomeExtensions =
      super.callPackage ./gnomeExtensions { inherit (super) gnomeExtensions; };
    mal_export = super.callPackage ./mal_export.nix { };
    terraform =
      super.callPackage ./terraform.nix { inherit (super) terraform; };
    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
