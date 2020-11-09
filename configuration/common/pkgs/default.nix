[
  (self: super: {
    mach-nix = import ./mach-nix.nix { pkgs = super; };
    resilio-sync = import ./resilio-sync.nix { pkgs = super; };
    python3 = import ./python3 { pkgs = super; };
  })
]
