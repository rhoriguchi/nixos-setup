{ callPackage }: {
  batteryEntity = callPackage ./batteryEntity.nix { };
  cardMod = callPackage ./cardMod.nix { };
  foldEntityRow = callPackage ./foldEntityRow.nix { };
  miniGraphCard = callPackage ./miniGraphCard.nix { };
  simpleThermostat = callPackage ./simpleThermostat.nix { };
}
