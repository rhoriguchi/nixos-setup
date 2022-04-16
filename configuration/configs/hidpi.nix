{ pkgs, lib, ... }: {
  # TODO boot selection is extremely small

  nixpkgs.overlays = [
    (self: super: {
      gimp = lib.lowPrio (super.gimp.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          substituteInPlace $out/etc/gimp/2.0/gimprc \
            --replace "# (icon-size auto)" "(icon-size huge)"
        '';
      }));

      spotify-unwrapped = lib.lowPrio (super.spotify-unwrapped.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/spotify \
            --add-flags "--force-device-scale-factor=2"
        '';
      }));
    })
  ];
}
