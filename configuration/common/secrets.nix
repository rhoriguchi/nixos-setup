{
  duckdns.token = "b2b4f5fd-3c52-4a5e-b27f-8f192ef75904";

  mal_export = {
    username = "XXLPitu";
    password = "37dkv9-myanimelist";
  };

  rslsync.secrets = [
    {
      secret = "AEOYQD5FF77ZMATGHXK7FH234POWZFIPK"; # Inspiration
    }
    {
      secret = "B6GGU4ROKGVPMV2FD3H64IS2JYF663AQM"; # Storage
    }
    {
      dirName = "mal_export";
      secret = "A4DQOIUDRED6ATZ2CTGGEYCA4J4DXV3CG";
    }
    {
      secret = "BJO6TZM3ZQJAVIQNPOWSAO36B7IGIKPME"; # Series
    }
    {
      dirName = "tv_time_export";
      secret = "AWZOJWZI226OEO3OX7BKGLKHHLGPYFTZT";
    }
    {
      secret = "BRJAASYDGV636RRFFT2BITA3ZXF3U2TNX"; # Exchange
    }
    {
      secret = "BVRR2WH2L7O723V6YQCV2SDKTHLSCXNX6"; # Documents
    }
    {
      secret = "BXQC56FGCI5YIKEY6UI3QG4QZ6VQFASIS"; # Git
    }
    {
      secret = "BZ66BHUEHJWE4AKBH3RU2GAPM5JOH2NK3"; # KeePass
    }
  ];

  tv_time_export = {
    username = "ryan.horiguchi@gmail.com";
    password = "37dkv9-tvtime";
  };

  users.users.xxlpitu.password = "37dkv9-3284-server";

  networking = {
    hostName = "XXLPitu-Rain-Town";

    wireless.networks = {
      "47555974".psk = "#tKRvgMKX0t6tUk1";
      "Horidoli".psk = "vY1v84HxfmntYP9m";
      "NO INTERNET ACCESS".psk = "ydwtqfCC46np";
    };
  };
}
