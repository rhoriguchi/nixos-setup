{ callPackage }: {
  battery-state-card = callPackage ./battery-state-card.nix { };
  card-mod = callPackage ./card-mod.nix { };
  fold-entity-row = callPackage ./fold-entity-row.nix { };
  mini-graph-card = callPackage ./mini-graph-card.nix { };
}
