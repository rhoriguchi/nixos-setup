{
  # > hyprctl clients
  wayland.windowManager.hyprland.settings.windowrule = [
    "suppress_event fullscreen, match:class code"
    "suppress_event fullscreen, match:class rustdesk"

    "tile on, match:class firefox, match:title .*Mozilla Firefox Private Browsing"

    "float on, match:class .blueman-manager-wrapped"
    "float on, match:class code, match:title Open Folder"
    "float on, match:class firefox, match:title ^(Extension: \\(Bitwarden Password Manager\\) - Bitwarden — Mozilla Firefox)$"
    "float on, match:class firefox, match:title File Upload"
    "float on, match:class org.gnome.seahorse.Application"
    "float on, match:class org.pulseaudio.pavucontrol"
    "float on, match:class solaar"
    "float on, match:class udiskie"
    "float on, match:class wpa_gui"

    "no_screen_share on, match:class code, match:title secrets.nix - .* - Visual Studio Code"
    "no_screen_share on, match:class discord"
    "no_screen_share on, match:class firefox, match:title .* \\| Bitwarden Web vault — Mozilla Firefox"
    "no_screen_share on, match:class firefox, match:title .* Discord \\| .* — Mozilla Firefox"
    "no_screen_share on, match:class firefox, match:title .*Gmail — Mozilla Firefox"
    "no_screen_share on, match:class firefox, match:title .*WhatsApp — Mozilla Firefox"
    "no_screen_share on, match:class firefox, match:title ^(Extension: \\(Bitwarden Password Manager\\) - Bitwarden — Mozilla Firefox)$"
    "no_screen_share on, match:class org.gnome.seahorse.Application"
    "no_screen_share on, match:class org.keepassxc.KeePassXC"
    "no_screen_share on, match:class org.telegram.desktop"
    "no_screen_share on, match:class signal"
    "no_screen_share on, match:class whatsapp-electron"
  ];
}
