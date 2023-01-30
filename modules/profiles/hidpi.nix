{
  # TODO boot selection is extremely small

  hardware.video.hidpi.enable = true;

  nixpkgs.overlays = [
    (_: super: {
      gimp = super.symlinkJoin {
        inherit (super.gimp) name;
        paths = [ super.gimp ];

        postBuild = ''
          cp --remove-destination $(realpath $out/etc/gimp/2.0/gimprc) $out/etc/gimp/2.0/gimprc
          substituteInPlace $out/etc/gimp/2.0/gimprc \
            --replace "# (icon-size auto)" "(icon-size huge)"
        '';
      };

      spotify-unwrapped = super.symlinkJoin {
        inherit (super.spotify-unwrapped) name;
        paths = [ super.spotify-unwrapped ];
        nativeBuildInputs = [ super.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/spotify \
            --add-flags "--force-device-scale-factor=2"
        '';
      };
    })
  ];
}
