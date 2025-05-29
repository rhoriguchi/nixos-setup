{ config, lib, pkgs, ... }: {
  imports = [
    ./_common.nix

    ./bluetooth.nix
    ./displaylink.nix
    ./git.nix
    ./gnome
    ./nautilus.nix
    ./printing.nix
    ./trash-management.nix
    ./util.nix
  ];

  environment.systemPackages = [
    pkgs.baobab
    pkgs.discord
    pkgs.firefox
    pkgs.ghostty
    pkgs.gimp3
    pkgs.gitkraken
    pkgs.glow
    pkgs.gnome-calculator
    pkgs.inkscape
    pkgs.jetbrains.datagrip
    pkgs.jetbrains.idea-ultimate
    pkgs.jetbrains.pycharm-professional
    pkgs.jetbrains.webstorm
    pkgs.loupe
    pkgs.mission-center
    pkgs.obsidian
    pkgs.prismlauncher # Minecraft
    pkgs.qbittorrent
    pkgs.rustdesk-flutter
    pkgs.signal-desktop
    pkgs.snapshot
  ] ++ lib.optional config.programs.dconf.enable pkgs.dconf-editor;
}
