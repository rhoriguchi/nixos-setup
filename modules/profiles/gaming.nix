{
  services.flatpak = {
    enable = true;

    uninstallUnmanaged = true;
    update.auto.enable = true;

    packages = [
      "org.prismlauncher.PrismLauncher" # Minecraft
    ];
  };

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
}
