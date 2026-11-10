{
  config,
  ...
}:
{
  imports = [
    ../common.nix

    ./print-server.nix
    ./wifi.nix
  ];

  time.timeZone = "Europe/Zurich";

  networking = {
    hostName = "XXLPitu-Ulquiorra";

    firewall.allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
      config.services.nginx.defaultSSLListenPort
    ];
  };
}
