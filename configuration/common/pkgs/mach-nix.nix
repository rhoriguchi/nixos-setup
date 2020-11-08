{ pkgs }:
(import (pkgs.fetchFromGitHub {
  owner = "DavHau";
  repo = "mach-nix";
  rev = "3.0.2";
  sha256 = "0w6i3wx9jyn29nnp6lsdk5kwlffpnsr4c80jk10s3drqyarckl2f";
}) { inherit pkgs; })
