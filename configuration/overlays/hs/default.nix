{ callPackage }: {
  lovelaceModule = callPackage ./lovelaceModule { };
  theme = callPackage ./theme { };
}
