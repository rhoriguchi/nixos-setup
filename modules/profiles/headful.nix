{ config, lib, pkgs, ... }: {
  imports = [
    ./_common.nix

    ./bluetooth.nix
    ./gaming.nix
    ./git.nix
    ./nautilus.nix
    ./peripherals.nix
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
    pkgs.google-chrome
    pkgs.inkscape
    pkgs.jetbrains.datagrip
    pkgs.jetbrains.idea-ultimate
    pkgs.jetbrains.pycharm-professional
    pkgs.jetbrains.webstorm
    pkgs.libreoffice-fresh
    pkgs.loupe
    pkgs.mission-center
    pkgs.obsidian
    pkgs.qbittorrent
    pkgs.rustdesk-flutter
    pkgs.signal-desktop
    pkgs.snapshot
    pkgs.vlc
    pkgs.wpa_supplicant_gui
  ] ++ lib.optional config.programs.dconf.enable pkgs.dconf-editor;
}
