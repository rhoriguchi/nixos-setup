{ pkgs, ... }:
{
  imports = [
    ./_common.nix

    ./bluetooth.nix
    ./dconf-editor.nix
    ./gaming.nix
    ./git.nix
    ./mission-center.nix
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
    pkgs.loupe
    pkgs.obsidian
    pkgs.qbittorrent
    pkgs.rustdesk-flutter
    pkgs.signal-desktop
    pkgs.snapshot
    pkgs.vlc
    pkgs.whatsapp-electron
    pkgs.wpa_supplicant_gui
  ];
}
