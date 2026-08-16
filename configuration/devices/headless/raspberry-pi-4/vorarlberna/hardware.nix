{ ... }:
{
  boot = {
    kernelParams = [ "cma=256M" ];

    # Makes the HDMI card the default ALSA device instead of the unused analog jack
    blacklistedKernelModules = [ "snd_bcm2835" ];
  };

  hardware.graphics.enable = true;

  services.udev.extraRules = ''
    KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
  '';
}
