{
  imports = [ ./swaync.nix ];

  services.swaync = {
    enable = true;

    systemd = {
      enable = true;

      target = "hyprland-session.target";
    };
  };
}
