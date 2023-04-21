{ pkgs }: {
  adguardhome = pkgs.callPackage ./adguardhome.nix { };
  home-assistant = pkgs.callPackage ./home-assistant.nix { };
  resilio = pkgs.callPackage ./resilio.nix { };
}
