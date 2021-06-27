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
in protonvpn-cli.overrideAttrs (_: {
  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp ${./icon.png} $out/share/pixmaps/proton-vpn.png

    mkdir -p $out/share/applications
    ln -s ${desktopItemConnect}/share/applications/* $out/share/applications
    ln -s ${desktopItemDisconnect}/share/applications/* $out/share/applications
  '';
})
