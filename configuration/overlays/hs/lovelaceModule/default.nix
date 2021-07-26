{ callPackage }: {
  batteryEntity = callPackage ./batteryEntity.nix { };
  foldEntityRow = callPackage ./foldEntityRow.nix { };
  miniGraphCard = callPackage ./miniGraphCard.nix { };
}
