{ pkgs, fetchFromGitHub }:
(import (fetchFromGitHub {
  owner = "DavHau";
  repo = "mach-nix";
  rev = "3.1.1";
  sha256 = "06bxmz7x1fnjx2d0gb63fdm0jci2mcdnpa3isbhjr92z1l2a7hl1";
}) { inherit pkgs; })
