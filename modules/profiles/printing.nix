{ pkgs, ... }: {
  services = {
    printing = {
      enable = true;

      webInterface = false;

      drivers = [
        pkgs.gutenprint
        pkgs.gutenprintBin
        pkgs.hplip
        pkgs.samsung-unified-linux-driver
        pkgs.splix
        pkgs.brlaser
        pkgs.brgenml1lpr
        pkgs.brgenml1cupswrapper
        pkgs.cnijfilter2
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };

  environment.systemPackages = [ pkgs.simple-scan ];
}
