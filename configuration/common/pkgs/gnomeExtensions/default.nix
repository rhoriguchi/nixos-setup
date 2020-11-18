{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  desktop-icons = callPackage ./desktop-icons.nix { };
}
