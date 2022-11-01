{ pkgs }: {
  home-assistant = pkgs.callPackage ./home-assistant.nix { };
  resilio = pkgs.callPackage ./resilio.nix { };
}
