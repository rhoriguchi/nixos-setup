{
  imports = [ ./guest.nix ./network.nix ./storage.nix ];

  security.polkit.enable = true;

  virtualisation.libvirtd.enable = true;
}
