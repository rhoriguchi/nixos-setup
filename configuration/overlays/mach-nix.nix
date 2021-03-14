{ pkgs, fetchFromGitHub }:
(import (fetchFromGitHub {
  owner = "DavHau";
  repo = "mach-nix";
  rev = "3.2.0";
  sha256 = "0qhg36l3c1i6p0p2l346fpj9zsh5kl0xpjmyasi1qcn7mbdfjb0m";
}) { inherit pkgs; })
