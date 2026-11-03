{
  config,
  lib,
  ...
}:
{
  sops.secrets = {
    "users/xxlpitu".neededForUsers = true;

    "alloy+services/loki/pushPassword" = {
      key = "services/loki/pushPassword";

      restartUnits = [ config.systemd.services.alloy.name ];
    };

    "alloy+services/prometheus/pushPassword" = {
      key = "services/prometheus/pushPassword";

      restartUnits = [ config.systemd.services.alloy.name ];
    };
  };

  # https://docs.kernel.org/next/admin-guide/sysctl/kernel.html
  boot.kernel.sysctl = {
    "kernel.panic" = 60;
    "kernel.panic_on_oops" = 1;
  };

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
    hashedPasswordFile = config.sops.secrets."users/xxlpitu".path;
  };

  services = {
    logShipping = {
      enable = true;

      receiverHostname = "XXLPitu-Tier";
      passwordFile = config.sops.secrets."alloy+services/loki/pushPassword".path;
    };

    metricShipping = {
      enable = true;

      receiverHostname = "XXLPitu-Tier";
      passwordFile = config.sops.secrets."alloy+services/prometheus/pushPassword".path;
    };

    tracesShipping = {
      enable = true;

      receiverHostname = "XXLPitu-Tier";
    };
  };

  documentation.enable = false;
}
