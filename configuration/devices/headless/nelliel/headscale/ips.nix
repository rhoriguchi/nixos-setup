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
    tags = [
      "admin"
      "headful"
    ];
  };
  XXLPitu-Nnoitra = {
    ip = "100.123.123.77";
    ssh = false;
    monitoring = false;
    tags = [
      "gaming"
      "headful"
    ];
  };

  # Headless
  XXLPitu-Kenpachi = {
    ip = "100.123.123.148";
    tags = [ "headless" ];
  };
  XXLPitu-Nelliel = {
    ip = "100.123.123.251";
    tags = [ "headless" ];
  };
  XXLPitu-Tier = {
    ip = "100.123.123.92";
    tags = [ "headless" ];
  };
  XXLPitu-Ulquiorra = {
    ip = "100.123.123.39";
    tags = [ "headless" ];
  };
  XXLPitu-Urahara = {
    ip = "100.123.123.113";
    tags = [
      "exit-node"
      "headless"
    ];
  };

  # Foreign
  Niels = {
    ip = "100.123.123.197";
    ssh = false;
    monitoring = false;
    tags = [ "gaming" ];
  };
}
