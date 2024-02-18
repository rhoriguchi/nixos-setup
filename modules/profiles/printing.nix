{ pkgs, ... }: {
  services = {
    printing = {
      enable = true;

      webInterface = false;

      drivers = [
        pkgs.brgenml1lpr
        pkgs.brlaser
        pkgs.gutenprint
        pkgs.gutenprintBin
        pkgs.hplip
        pkgs.hplipWithPlugin
        pkgs.postscript-lexmark
        pkgs.samsung-unified-linux-driver
        pkgs.splix
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  environment.systemPackages = [ pkgs.simple-scan ];
}
