{ lib }:
let
  trustedNetworks = [
    "63466727"
    "63466727-Guest"
    "63466727-IoT"
    "Niflheim"
  ];

  disableEhtNetworks = [
    "63466727"
    "63466727-Guest"
    "63466727-IoT"
  ];

  networks = {
    "63466727".authProtocols = [ "SAE" ];
    "63466727-Guest".authProtocols = [ "SAE" ];
    "63466727-IoT".authProtocols = [ "SAE" ];

    Niflheim.authProtocols = [ "WPA-PSK" ];

    "47555974".authProtocols = [ "WPA-PSK" ];
    FastAfBoi.authProtocols = [ "WPA-PSK" ];
    Horidoli.authProtocols = [ "WPA-PSK" ];
    "NO INTERNET ACCESS".authProtocols = [ "WPA-PSK" ];
    NoWIFI4U.authProtocols = [ "WPA-PSK" ];
    "Streng Guest".authProtocols = [ "WPA-PSK" ];
    TartarosDotHell.authProtocols = [ "WPA-PSK" ];
  };

  mkExtraConfig =
    ssid: authProtocols:
    {
      headless ? false,
    }:
    lib.concatStringsSep "\n" (
      lib.optional (lib.elem "SAE" authProtocols) "ieee80211w=2"
      ++ [ "mac_addr=${if headless || lib.elem ssid trustedNetworks then "0" else "2"}" ]
      ++ lib.optional (lib.elem ssid disableEhtNetworks) "disable_eht=1"
    );

  mkNetworks =
    psks:
    lib.mapAttrs (ssid: value: {
      inherit (value) authProtocols;
      psk = psks.${ssid};
      extraConfig = mkExtraConfig ssid value.authProtocols { };
    }) networks;
in
{
  inherit mkExtraConfig mkNetworks;
}
