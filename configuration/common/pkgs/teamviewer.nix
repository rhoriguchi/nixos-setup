{ teamviewer }:
teamviewer.overrideAttrs (oldAttrs: {
  installPhase = oldAttrs.installPhase + ''
    # TODO does not work
    for i in 16 20 24 32 48 256; do
      size=$i"x"$i

      mkdir -p $out/share/icons/hicolor/$size/apps
      ln -s $out/share/teamviewer/tv_bin/desktop/teamviewer_$i.png $out/share/icons/hicolor/$size/apps/TeamViewer.png
    done;
  '';
})
