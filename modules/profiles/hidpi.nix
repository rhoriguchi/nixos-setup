{
  nixpkgs.overlays = [
    (_: super: {
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
