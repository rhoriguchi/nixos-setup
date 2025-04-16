# Manually map output https://github.com/NixOS/nix/issues/4945#issuecomment-868572873
{
  containers = ./containers.nix;
  displaylink = ./displaylink.nix;
  docker = ./docker.nix;
  fwupd = ./fwupd.nix;
  git = ./git.nix;
  gnome = ./gnome;
  headful = ./headful.nix;
  headless = ./headless.nix;
  i18n = ./i18n.nix;
  java = ./java.nix;
  javascript = ./javascript.nix;
  keyboard = ./keyboard.nix;
  kotlin = ./kotlin.nix;
  laptop-power-management = ./laptop-power-management.nix;
  nautilus = ./nautilus.nix;
  nftables = ./nftables.nix;
  nginx = ./nginx.nix;
  nix = ./nix.nix;
  nvd = ./nvd.nix;
  podman = ./podman.nix;
  printing = ./printing.nix;
  python = ./python.nix;
  shell = ./shell.nix;
  tmp-management = ./tmp-management.nix;
  trash-management = ./trash-management.nix;
  util = ./util.nix;
  virtualbox = ./virtualbox.nix;
  zfs = ./zfs.nix;
}
