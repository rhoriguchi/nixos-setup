{
  boot = {
    kernelParams = [
      # Show a QR code with kernel log data on kernel panic
      "drm.panic_screen=qr_code"

      # Enable root user in rescue shell
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];
  };
}
