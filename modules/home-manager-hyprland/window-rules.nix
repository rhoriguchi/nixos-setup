{
  # > hyprctl clients
  wayland.windowManager.hyprland.settings.windowrule = [
    "float, class:.blueman-manager-wrapped"
    "float, class:code, title:Open Folder"
    # TODO HYPRLAND does not work
    "float, class:firefox, title:^(Extension: \\(Bitwarden Password Manager\\).*)$"
    # TODO HYPRLAND does not work
    "float, class:firefox, title:^(Extension: \\(Open in Browser\\).*)$"
    "float, class:firefox, title:File Upload"
    "float, class:org.gnome.seahorse.Application"
    "float, class:org.pulseaudio.pavucontrol"
    "float, class:solaar"
    "float, class:wpa_gui"
  ];
}
