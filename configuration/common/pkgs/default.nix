[
  (self: super: {
    # TODO how to solve this with inheritance?
    mach-nix = super.callPackage ./mach-nix.nix { pkgs = super; };
    # TOOD split this in a previous overlay so that mach-nix can use it
    python3 = super.callPackage ./python3 { inherit (super) python3; };
  })
  (self: super: {
    glances = super.callPackage ./glances.nix { inherit (super) glances; };
    # TODO how to solve this with no inheritance?
    mal_export =
      super.callPackage ./mal_export.nix { inherit (super) mach-nix; };
    resilio-sync =
      super.callPackage ./resilio-sync.nix { inherit (super) resilio-sync; };
    # TODO how to solve this with no inheritance?
    tv_time_export =
      super.callPackage ./tv_time_export.nix { inherit (super) mach-nix; };
  })
]
