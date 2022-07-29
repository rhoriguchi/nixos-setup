{ callPackage }: {
  lovelaceModule = callPackage ./lovelace-module { };
  theme = callPackage ./theme { };
}
