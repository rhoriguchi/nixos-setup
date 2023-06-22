{
  nixpkgs.overlays = [
    (_: super: {
      gimp = super.gimp.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          substituteInPlace $out/etc/gimp/2.0/gimprc \
            --replace "# (icon-size auto)" "(icon-size huge)"
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

  # TODO option was remove, replace with http://wiki.hyprland.org/Configuring/XWayland/#hidpi-xwayland
  # programs.hyprland.xwayland.hidpi = true;

  services.xserver.displayManager.sddm.enableHidpi = true;
}
