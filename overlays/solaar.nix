{ solaar, symlinkJoin }:
symlinkJoin {
  inherit (solaar) name pname udev;
  paths = [ solaar ];

  postBuild = ''
    cp --remove-destination $(realpath $out/share/applications/solaar.desktop) $out/share/applications/solaar.desktop
    substituteInPlace $out/share/applications/solaar.desktop \
      --replace "Exec=solaar" "Exec=solaar -w hide"
  '';
}
