{ libCustom, ... }:
{
  # > hyprctl clients
  wayland.windowManager.hyprland.settings.window_rule =
    libCustom.hyprland.mkWindowRules { suppress_event = "fullscreen"; } [
      { class = "code"; }
      { class = "rustdesk"; }
    ]
    ++ libCustom.hyprland.mkWindowRules { tile = true; } [
      {
        class = "firefox";
        title = ".*Mozilla Firefox Private Browsing";
      }
    ]
    ++ libCustom.hyprland.mkWindowRules { float = true; } [
      { class = ".blueman-manager-wrapped"; }
      {
        class = "code";
        title = "Open Folder";
      }
      {
        class = "firefox";
        title = "^(Extension: \\(Bitwarden Password Manager\\) - Bitwarden — Mozilla Firefox)$";
      }
      {
        class = "firefox";
        title = "File Upload";
      }
      { class = "org.gnome.seahorse.Application"; }
      { class = "org.pulseaudio.pavucontrol"; }
      { class = "solaar"; }
      { class = "udiskie"; }
      { class = "wpa_gui"; }
    ]
    ++ libCustom.hyprland.mkWindowRules { no_screen_share = true; } [
      {
        class = "code";
        title = ".*secrets.nix - .* - Visual Studio Code";
      }
      { class = "discord"; }
      {
        class = "firefox";
        title = ".* \\| Bitwarden Web vault — Mozilla Firefox";
      }
      {
        class = "firefox";
        title = ".* Discord \\| .* — Mozilla Firefox";
      }

      {
        class = "firefox";
        title = ".*Gmail — Mozilla Firefox";
      }
      {
        class = "firefox";
        title = ".*WhatsApp — Mozilla Firefox";
      }
      {
        class = "firefox";
        title = "^(Extension: \\(Bitwarden Password Manager\\) - Bitwarden — Mozilla Firefox)$";
      }
      {
        class = "firefox";
        title = "Cashew — Mozilla Firefox";
      }
      { class = "org.gnome.seahorse.Application"; }
      { class = "org.keepassxc.KeePassXC"; }
      { class = "org.telegram.desktop"; }
      { class = "signal"; }
      { title = "WhatsApp .*"; }
    ];
}
