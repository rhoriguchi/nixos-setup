[
  (self: super: {
    mach-nix = import ./mach-nix.nix { pkgs = super; };
    python3 = import ./python3 { pkgs = super; };
  })
]
