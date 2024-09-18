{ pkgs, ... }: {
  hardware.printers.ensurePrinters = [{
    name = "Default";

    # lpinfo -v
    deviceUri = "hp:/usb/ENVY_4500_series?serial=CN4CS2325205X4";

    # lpinfo -m
    model = "HP/hp-envy_4500_series.ppd.gz";

    # lpoptions -p Default -l
    ppdOptions = {
      ColorModel = "KGray";
      Duplex = "None";
      InputSlot = "Auto";
      MediaType = "Plain";
      OptionDuplex = "False";
      OutputMode = "Normal";
      PageSize = "A4";
    };
  }];

  services = {
    # lsusb
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="03f0", ENV{ID_MODEL_ID}=="c511", RUN+="${pkgs.systemd}/bin/systemctl restart ensure-printers.service"
    '';

    printing = {
      enable = true;

      stateless = true;

      webInterface = true;
      startWhenNeeded = false;

      # Firewall port needs to be open and listen address needs to be 0.0.0.0 else discovery does not work
      openFirewall = true;
      listenAddresses = [ "0.0.0.0:631" ];
      allowFrom = [ "127.0.0.1" "192.168.1.*" ];
      browsing = true;
      defaultShared = true;

      drivers = [ pkgs.hplipWithPlugin ];

      extraConf = ''
        DefaultEncryption Never
      '';
    };

    avahi = {
      enable = true;

      openFirewall = true;

      nssmdns4 = true;
      nssmdns6 = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
