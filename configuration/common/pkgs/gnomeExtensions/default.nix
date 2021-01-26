{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  fuzzy-app-search = callPackage ./fuzzy-app-search { };
}
