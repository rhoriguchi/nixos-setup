{ pkgs, ... }:
{
  environment.cosmic.excludePackages = [
    #   pkgs.adwaita-icon-theme
    #   pkgs.alsa-utils
    pkgs.cosmic-edit
    #   pkgs.cosmic-icons
    pkgs.cosmic-player
    #   pkgs.cosmic-randr
    pkgs.cosmic-reader
    #   pkgs.cosmic-screenshot
    pkgs.cosmic-store
    pkgs.cosmic-term
    #   pkgs.cosmic-wallpapers
    #   pkgs.glib
    #   pkgs.hicolor-icon-theme
    #   pkgs.networkmanagerapplet
    pkgs.playerctl
    #   pkgs.pop-icon-theme
    #   pkgs.pop-launcher
    #   pkgs.pulseaudio
    #   pkgs.xdg-user-dirs
  ];

  services = {
    displayManager.cosmic-greeter.enable = true;

    desktopManager.cosmic.enable = true;

    system76-scheduler.enable = true;
  };
}
