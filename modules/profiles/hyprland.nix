{ pkgs, ... }: {
  security.pam.services.swaylock.text = ''
    auth include login
  '';

  systemd.services."display-manager".after = [ "network-online.target" "systemd-resolved.service" ];

  services = {
    pipewire.enable = true;

    udisks2.enable = true;

    logind = {
      # TODO replace with suspend-then-hibernate
      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
      # TODO replace with suspend-then-hibernate
      lidSwitch = "suspend";
    };

    xserver = {
      enable = true;

      displayManager = {
        defaultSession = "hyprland";

        sddm = {
          enable = true;

          settings.Autologin.Session = "hyprland.desktop";
        };
      };

      excludePackages = [ pkgs.xterm ];
    };
  };

  programs.hyprland.enable = true;

  networking.networkmanager.enable = true;
}
