{ htop, alacritty }:
htop.overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    substituteInPlace $out/share/applications/htop.desktop \
      --replace "Terminal=true" "Terminal=false" \
      --replace "Exec=htop" "Exec=${alacritty}/bin/alacritty -e htop"
  '';
})
