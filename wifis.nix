{ lib }:
let
  trustedNetworks = [
    "63466727"
    "63466727-Guest"
    "63466727-IoT"
    "Hueco Mundo"
  ];

  disableEhtNetworks = [
    "63466727"
    "63466727-Guest"
    "63466727-IoT"
  ];

  only24GhzNetworks = [
    "CLARO_WIFI"
  ];

  networks = {
    "63466727".authProtocols = [ "SAE" ];
    "63466727-Guest".authProtocols = [ "SAE" ];
    "63466727-IoT".authProtocols = [ "SAE" ];

    "Hueco Mundo".authProtocols = [ "WPA-PSK" ];

    "47555974".authProtocols = [ "WPA-PSK" ];
    CLARO_WIFI.authProtocols = [ "WPA-PSK" ];
    FastAfBoi.authProtocols = [ "WPA-PSK" ];
    Horidoli.authProtocols = [ "WPA-PSK" ];
    NETGEAR89.authProtocols = [ "WPA-PSK" ];
    "NO INTERNET ACCESS".authProtocols = [ "WPA-PSK" ];
    NoWIFI4U.authProtocols = [ "WPA-PSK" ];
    palace.authProtocols = [ "WPA-PSK" ];
    PALACE.authProtocols = [ "WPA-PSK" ];
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
      ++ lib.optional (lib.elem ssid only24GhzNetworks) "freq_list=${
        lib.pipe (lib.range 1 13) [
          (map (channel: 2407 + 5 * channel))
          (frequencies: frequencies ++ [ 2484 ])
          (lib.concatMapStringsSep " " toString)
        ]
      }"
    );

  wirelessNetworks = lib.mapAttrs (
    ssid: value:
    {
      inherit (value) authProtocols;
      extraConfig = mkExtraConfig ssid value.authProtocols { };
    }
    // lib.optionalAttrs (value.authProtocols != [ "NONE" ]) { pskRaw = "ext:${ssid}"; }
  ) networks;

  passwordSsids = lib.attrNames (lib.filterAttrs (_: network: network ? pskRaw) wirelessNetworks);
in
{
  inherit
    trustedNetworks
    mkExtraConfig
    wirelessNetworks
    passwordSsids
    ;
}
