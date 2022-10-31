{ pkgs }: {
  home-assistant = import ./home-assistant.nix { inherit pkgs; };
  resilio = import ./resilio.nix { inherit pkgs; };
}
