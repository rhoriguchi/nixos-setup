{ config, ... }: {
  imports = [ ./guest.nix ./network.nix ./storage.nix ];

  security.polkit.enable = true;

  virtualisation.libvirtd.enable = true;

  networking.hosts."172.16.1.1" = [ "${config.networking.hostName}.local" ];
}
