{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.prismlauncher # Minecraft
  ];
}
