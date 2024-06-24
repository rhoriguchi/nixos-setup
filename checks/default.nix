{ pkgs }: {
  adguardhome = pkgs.callPackage ./adguardhome.nix { };

  # TODO uncomment when https://github.com/project-chip/connectedhomeip/issues/25688 fixed
  # home-assistant = pkgs.callPackage ./home-assistant.nix { };

  resilio = pkgs.callPackage ./resilio.nix { };
}
