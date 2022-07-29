{ solaar }:
solaar.overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    substituteInPlace $out/share/applications/solaar.desktop \
      --replace "Exec=solaar" "Exec=solaar -w hide"
  '';
})
