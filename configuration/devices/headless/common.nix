{
  config,
  lib,
  secrets,
  ...
}:
{
  imports = [ ../../common.nix ];

  documentation.enable = false;

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  users.users.xxlpitu = {
    extraGroups = [
      "wheel"
    ]
    ++ (lib.optional config.virtualisation.docker.enable "docker")
    ++ (lib.optional config.virtualisation.podman.enable "podman")
    ++ (lib.optionals config.virtualisation.libvirtd.enable [
      "kvm"
      "libvirtd"
    ])
    ++ (lib.optional config.virtualisation.virtualbox.host.enable "vboxusers");
    isNormalUser = true;
    password = secrets.users.xxlpitu.password;
  };

  services = {
    logShipping = {
      enable = true;

      receiverHostname = "XXLPitu-Tier";
    };

    monitoring = {
      enable = true;

      type = "child";
      parentHostname = "XXLPitu-Tier";
      apiKey = secrets.monitoring.apiKey;
    };

    networkTopology = {
      enable = true;

      serverHostname = "XXLPitu-Tier";
      inherit (secrets.netvisor) apiKey;
    };
  };
}
