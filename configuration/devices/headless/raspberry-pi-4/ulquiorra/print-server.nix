{ pkgs, ... }: {
  hardware.printers.ensurePrinters = [{
    name = "DeskJet-3700";
    deviceUri = "hp:/usb/DeskJet_3700_series?serial=CN8CA6P2F706GZ";

    # lpinfo -m
    model = "HP/hp-deskjet_3700_series.ppd.gz";

    # lpoptions -p DeskJet-3700
    ppdOptions = {
      ColorModel = "KGray";
      InputSlot = "Upper";
      MediaType = "Plain";
      PageSize = "A4";
    };
  }];

  services = {
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

      drivers = [ pkgs.hplip ];

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
