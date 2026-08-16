{ ... }:
{
  boot.kernelParams = [ "cma=256M" ];

  hardware = {
    graphics.enable = true;

    # Fix boot issue on some TVs / allow full 4K@60Hz HDMI clock config.
    # https://www.raspberrypi.com/documentation/computers/config_txt.html#hdmi_enable_4kp60
    raspberry-pi.config.all.options."hdmi_enable_4kp60" = {
      value = "1";
      enable = true;
    };
  };

  services.udev.extraRules = ''
    KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
  '';
}
