{ pkgs, ... }:
(pkgs.python3.override {
  packageOverrides = self: super: {
    wifi = import ./wifi.nix { pkgs = super; };
  };
})
