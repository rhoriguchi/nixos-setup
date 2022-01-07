{ pkgs, ... }: {
  # TODO boot selection is extremely small
  # TODO flameshot icons are to small

  nixpkgs.overlays = [
    (self: super: {
      foxitreader = super.foxitreader.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/FoxitReader \
            --set QT_AUTO_SCREEN_SCALE_FACTOR 1
        '';
      });

      gimp = super.gimp.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          substituteInPlace $out/etc/gimp/2.0/gimprc \
            --replace "# (icon-size auto)" "(icon-size huge)"
        '';
      });

      spotify = super.spotify-unwrapped.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/spotify \
            --add-flags "--force-device-scale-factor=2"
        '';
      });
    })
  ];
}
