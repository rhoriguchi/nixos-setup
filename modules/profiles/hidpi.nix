{
  nixpkgs.overlays = [
    (_: super: {
      gimp = super.gimp.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          substituteInPlace $out/etc/gimp/2.0/gimprc \
            --replace-fail "# (icon-size auto)" "(icon-size huge)"
        '';
      });

      spotify = super.spotify.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ super.makeWrapper ];

        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/spotify \
            --add-flags "--force-device-scale-factor=2"
        '';
      });
    })
  ];
}
