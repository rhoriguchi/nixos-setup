{ protonvpn-cli, makeDesktopItem, bash }:
let
  desktopItemConnect = makeDesktopItem {
    name = "proton-vpn-cli-connect";
    desktopName = "ProtonVPN connect";
    exec = ''${bash}/bin/bash -c "sudo protonvpn connect --fastest"'';
    startupNotify = true;
    terminal = true;
    type = "Application";
    icon = "proton-vpn";
  };

  desktopItemDisconnect = makeDesktopItem {
    name = "proton-vpn-cli-disconnect";
    desktopName = "ProtonVPN disconnect";
    exec = ''${bash}/bin/bash -c "sudo protonvpn disconnect"'';
    startupNotify = true;
    terminal = true;
    type = "Application";
    icon = "proton-vpn";
  };
in protonvpn-cli.overrideAttrs (oldAttrs: {
  installPhase = ''
    mkdir -p $out/share/icons
    cp ${./icon.png} $out/share/icons/proton-vpn.png

    mkdir -p $out/share/applications
    cp ${desktopItemConnect}/share/applications/${desktopItemConnect.name} $out/share/applications
    cp ${desktopItemDisconnect}/share/applications/${desktopItemDisconnect.name} $out/share/applications
  '';
})
