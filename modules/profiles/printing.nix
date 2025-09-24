{ pkgs, ... }:
{
  services = {
    printing = {
      enable = true;

      webInterface = false;

      drivers = [
        pkgs.brgenml1lpr
        pkgs.brlaser
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
