{ lib, config, public-keys, secrets, ... }: {
  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 7d";
  };

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  users.users.xxlpitu = {
    extraGroups = [ "wheel" ] ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optional config.virtualisation.podman.enable "podman")
      ++ (lib.optionals config.virtualisation.libvirtd.enable [ "kvm" "libvirtd" ]);
    isNormalUser = true;
    password = secrets.users.xxlpitu.password;
    openssh.authorizedKeys.keys = [ public-keys.default ];
  };
}
