{ pkgs, ... }:
{
  services = {
    printing = {
      enable = true;

      webInterface = false;

      package = pkgs.symlinkJoin {
        inherit (pkgs.cups) name;
        paths = [ pkgs.cups ];

        postBuild = ''
          rm $out/share/applications/cups.desktop
        '';
      };

      drivers = [
        pkgs.cups-browsed
        pkgs.cups-filters

        pkgs.brgenml1lpr
        pkgs.brlaser
        pkgs.cnijfilter2
        pkgs.epson-escpr
        pkgs.epson-escpr2
        pkgs.gutenprint
        pkgs.gutenprintBin
        pkgs.hplipWithPlugin
        pkgs.postscript-lexmark
        pkgs.samsung-unified-linux-driver
        pkgs.splix
      ];
    };

    avahi = {
      enable = true;

      openFirewall = true;

      nssmdns4 = true;
      nssmdns6 = true;
    };
  };
}
