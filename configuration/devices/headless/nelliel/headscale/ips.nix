{
  # need to be in subnet 100.123.123.0/24
  # ssh defaults to true when omitted
  # monitoring defaults to true when omitted

  headplane-agent = {
    ip = "100.123.123.1";
    ssh = false;
    monitoring = false;
  };

  # Headless
  XXLPitu-Aizen = {
    ip = "100.123.123.35";
    monitoring = false;
  };
  XXLPitu-Nnoitra = {
    ip = "100.123.123.77";
    ssh = false;
    monitoring = false;
  };

  # Headless
  XXLPitu-Kenpachi.ip = "100.123.123.148";
  XXLPitu-Nelliel.ip = "100.123.123.251";
  XXLPitu-Tier.ip = "100.123.123.92";
  XXLPitu-Ulquiorra.ip = "100.123.123.39";
  XXLPitu-Urahara.ip = "100.123.123.113";
}
