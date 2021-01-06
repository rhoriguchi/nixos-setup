{ teamviewer }:
teamviewer.overrideAttrs (oldAttrs: {
  installPhase = oldAttrs.installPhase + ''
    wrapQtApp $out/share/teamviewer/tv_bin/script/teamviewer
  '';
})
