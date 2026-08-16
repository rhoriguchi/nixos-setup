{ config, ... }:
let
  inherit (config.lib.topology) mkConnection;

  ips = import ../configuration/devices/headless/urahara/dhcp/ips.nix;

  keaNetwork = id: "XXLPitu-Urahara-kea-${toString id}";
in
{
  networks = {
    "${keaNetwork 1}".name = "LAN";
    "${keaNetwork 2}".name = "Trusted";
    "${keaNetwork 3}".name = "IoT";
    "${keaNetwork 10}".name = "DMZ";
    "${keaNetwork 100}".name = "Guest";

    "${keaNetwork 999}".name = "br0";
  };

  nodes = {
    XXLPitu-Urahara.interfaces.eth3.physicalConnections = [
      (mkConnection "networkClosetSwitch" "uplink")
    ];

    XXLPitu-Aizen.interfaces.wlp0s20f3.network = keaNetwork 2;

    XXLPitu-Ulquiorra.interfaces.wlan0.network = keaNetwork 3;
    XXLPitu-Vorarlberna.interfaces.eth0.network = keaNetwork 3;

    XXLPitu-Tier.interfaces.enp11s0 = {
      addresses = [ ips.tier ];
      network = keaNetwork 10;
    };

    networkClosetSwitch = {
      name = "Network closet - USW Pro XG 8 PoE";
      deviceType = "switch";
      hardware.image = ./images/usw-pro-xg-8-poe.png;

      interfaces = {
        uplink.sharesNetworkWith = [ ];

        office = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "officeSwitch" "uplink") ];
        };
        livingRoom = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "livingRoomSwitch" "uplink") ];
        };
        bedroom = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "bedroomAp" "uplink") ];
        };
        cloudKey = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "cloudKey" "uplink") ];
        };
      };
    };

    officeSwitch = {
      name = "Office - USW Pro XG 8 PoE";
      deviceType = "switch";
      hardware.image = ./images/usw-pro-xg-8-poe.png;

      interfaces = {
        uplink.sharesNetworkWith = [ ];

        ap = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "officeAp" "uplink") ];
        };
        tier = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "XXLPitu-Tier" "enp11s0") ];
        };
      };
    };

    livingRoomSwitch = {
      name = "Living room - US 8 60W";
      deviceType = "switch";
      hardware.image = ./images/us-8-60w.png;

      interfaces = {
        uplink.sharesNetworkWith = [ ];

        ap = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "livingRoomAp" "uplink") ];
        };
        vorarlberna = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "XXLPitu-Vorarlberna" "eth0") ];
        };
      };
    };

    officeAp = {
      name = "Office - U7 Pro XG";
      deviceType = "device";
      hardware.image = ./images/u7-pro-xg.png;

      interfaces = {
        uplink.sharesNetworkWith = [ ];

        ulquiorra = {
          sharesNetworkWith = [ ];
          physicalConnections = [ (mkConnection "XXLPitu-Ulquiorra" "wlan0") ];
        };
      };
    };

    livingRoomAp = {
      name = "Living room - U6 LR";
      deviceType = "device";
      hardware.image = ./images/u6-lr.png;
      interfaces.uplink = { };
    };

    bedroomAp = {
      name = "Bedroom - U7 Pro XG";
      deviceType = "device";
      hardware.image = ./images/u7-pro-xg.png;
      interfaces.uplink = { };
    };

    cloudKey = {
      name = "Cloud Key Gen.2";
      deviceType = "device";
      hardware.image = ./images/cloudkey-gen2.png;

      interfaces.uplink = {
        addresses = [ ips.cloudKey ];
        network = keaNetwork 1;
      };
    };
  };
}
