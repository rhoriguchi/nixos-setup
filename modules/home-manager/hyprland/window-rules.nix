{
  # > hyprctl clients
  wayland.windowManager.hyprland.extraConfig = ''
    windowrulev2 = float, class:^(code)$, title:^(Open Folder)$
    windowrulev2 = float, class:^(file-roller)$, title:^(Archive Manager)$
    windowrulev2 = float, class:^(firefox)$, title:^(Extension: \(Bitwarden - Free Password Manager\) - Bitwarden —.*)$  # TODO does not work
    windowrulev2 = float, class:^(firefox)$, title:^(Extension: \(Open in Browser\) -.*)$  # TODO does not work
    windowrulev2 = float, class:^(firefox)$, title:^(Library)$
    windowrulev2 = float, class:^(firefox)$, title:^(Picture-in-Picture)$
    windowrulev2 = float, class:^(org\.gnome\.baobab)$
    windowrulev2 = float, class:^(org\.gnome\.Nautilus)$
    windowrulev2 = float, class:^(org\.keepassxc\.KeePassXC)$
    windowrulev2 = float, class:^(pavucontrol)$
    windowrulev2 = float, class:^(solaar)$
    windowrulev2 = float, class:^(Steam)$, title:^(Steam - News)$
    windowrulev2 = float, class:^(TeamViewer)$, title:^(TeamViewer)$ # TODO when viewing other desktop it's floating
    windowrulev2 = float, class:^(virt-manager)$, title:^(Virtual Machine Manager)$ # TODO does not work
    windowrulev2 = float, class:^(wpa_gui)$

    windowrulev2 = noborder, class:^(discord)$, title:^(Discord Updater)$
  '';
}
