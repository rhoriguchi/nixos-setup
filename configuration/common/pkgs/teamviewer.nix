{ fetchzip }:
# TODO temp fix till in nixpkgs-unstable https://github.com/NixOS/nixpkgs/pull/114653
let
  pkgs = import (fetchzip {
    url =
      "https://github.com/NixOS/nixpkgs/archive/4a7f99d55d299453a9c2397f90b33d1120669775.tar.gz";
    sha256 = "14sdgw2am5k66im2vwb8139k5zxiywh3wy6bgfqbrqx2p4zlc3m7";
  }) { config = { allowUnfree = true; }; };
in pkgs.teamviewer
