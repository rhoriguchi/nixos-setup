{
  networking.usePredictableInterfaceNames = false;

  systemd.network.links = {
    # RJ45
    "10-eth0" = {
      matchConfig.PermanentMACAddress = "00:f0:cb:fe:c1:d4";
      linkConfig.Name = "eth0";
    };
    "10-eth1" = {
      matchConfig.PermanentMACAddress = "00:f0:cb:fe:c1:d5";
      linkConfig.Name = "eth1";
    };
    "10-eth2" = {
      matchConfig.PermanentMACAddress = "00:f0:cb:fe:c1:d6";
      linkConfig.Name = "eth2";
    };

    # Intel 82599ES - SFP+
    "10-eth3" = {
      matchConfig.PermanentMACAddress = "00:f0:cb:fe:c8:d5";
      linkConfig = {
        Name = "eth3";
        AutoNegotiation = false;
        BitsPerSecond = "10G";
        Duplex = "full";
      };
    };
    "10-eth4" = {
      matchConfig.PermanentMACAddress = "00:f0:cb:fe:c8:d6";
      linkConfig = {
        Name = "eth4";
        AutoNegotiation = false;
        BitsPerSecond = "10G";
        Duplex = "full";
      };
    };

    "10-wlan0" = {
      matchConfig.PermanentMACAddress = "4c:44:5b:7b:d4:8c";
      linkConfig.Name = "wlan0";
    };
  };
}
