{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.baobab
    pkgs.discord
    pkgs.firefox
    pkgs.ghostty
    pkgs.glow
    pkgs.gnome-calculator
    pkgs.loupe
    pkgs.obsidian
    pkgs.pavucontrol
    pkgs.qbittorrent
    pkgs.rustdesk-flutter
    pkgs.signal-desktop
    pkgs.snapshot
    pkgs.vlc
    pkgs.whatsapp-electron
    pkgs.wl-clipboard
    pkgs.wpa_supplicant_gui
  ];
}
