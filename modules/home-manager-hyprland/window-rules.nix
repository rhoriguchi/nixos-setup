{
  # > hyprctl clients
  wayland.windowManager.hyprland.settings.windowrule = [
    "suppressevent fullscreen, class:Code"
    "suppressevent fullscreen, class:rustdesk"

    "tile, class:firefox, title:.*Mozilla Firefox Private Browsing"

    "float, class:.blueman-manager-wrapped"
    "float, class:Code, title:Open Folder"
    "float, class:firefox, title:^(Extension: \\(Bitwarden Password Manager\\) - Bitwarden — Mozilla Firefox)$"
    "float, class:firefox, title:File Upload"
    "float, class:org.gnome.seahorse.Application"
    "float, class:org.pulseaudio.pavucontrol"
    "float, class:solaar"
    "float, class:udiskie"
    "float, class:wpa_gui"

    "noscreenshare, class:Code, title: secrets.nix - .* - Visual Studio Code"
    "noscreenshare, class:discord"
    "noscreenshare, class:firefox, title:.* \\| Bitwarden Web vault — Mozilla Firefox"
    "noscreenshare, class:firefox, title:.* Discord \\| .* — Mozilla Firefox"
    "noscreenshare, class:firefox, title:.*Gmail — Mozilla Firefox"
    "noscreenshare, class:firefox, title:.*WhatsApp — Mozilla Firefox"
    "noscreenshare, class:firefox, title:^(Extension: \\(Bitwarden Password Manager\\) - Bitwarden — Mozilla Firefox)$"
    "noscreenshare, class:org.gnome.seahorse.Application"
    "noscreenshare, class:org.keepassxc.KeePassXC"
    "noscreenshare, class:org.telegram.desktop"
    "noscreenshare, class:signal"
    "noscreenshare, class:whatsapp-electron"
  ];
}
