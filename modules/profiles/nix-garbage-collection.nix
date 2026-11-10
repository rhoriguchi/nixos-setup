{
  services.harmonia.gc = {
    enable = true;

    automatic = true;
    dates = "05:00";

    deleteOlderThan = "7d";
    keepRecent = "7d";
  };
}
