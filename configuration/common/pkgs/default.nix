[
  (self: super: {
    mach-nix = super.callPackage ./mach-nix.nix { pkgs = super; };
  })
  (self: super: {
    glances = super.callPackage ./glances.nix { inherit (super) glances; };
    mal_export = super.callPackage ./mal_export.nix { };
    resilio-sync =
      super.callPackage ./resilio-sync.nix { inherit (super) resilio-sync; };
    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
