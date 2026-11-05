{ ... }:
{
  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      # Blueman
      { settings."org/blueman/general".plugin-list = [ "!ConnectionNotifier" ]; }
    ];
  };
}
