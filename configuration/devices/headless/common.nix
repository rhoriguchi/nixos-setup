{
  config,
  lib,
  secrets,
  ...
}:
let
  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
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
    log-shipping = {
      enable = true;

      receiverHostname = "XXLPitu-Tier";
    };

    monitoring = {
      enable = true;

      type = "child";
      parentHostname = "XXLPitu-Tier";
      apiKey = secrets.monitoring.apiKey;
    };

    # TODO create module?
    netvisor.daemon = {
      enable = true;

      name = config.networking.hostName;

      serverTarget = "http://${tailscaleIps.XXLPitu-Tier}";
      daemonApiKey = "${secrets.netvisor.apiKey}";
      # TODO expose readonly in module
      networkId = "92e3eb07-8cd7-4c8b-bfa4-3e67c109eebd";

      # TODO REMOVE ME
      logLevel = "debug";
    };
  };
}
