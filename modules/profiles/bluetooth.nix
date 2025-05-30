{ pkgs, ... }: {
  hardware.bluetooth.enable = true;

  environment.systemPackages = [ pkgs.blueman ];

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      # Blueman
      { settings."org/blueman/general".plugin-list = [ "!ConnectionNotifier" ]; }
    ];
  };
}
