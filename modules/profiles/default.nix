# Manually map output https://github.com/NixOS/nix/issues/4945#issuecomment-868572873
{
  headful = ./headful.nix;
  headless = ./headless.nix;

  bluetooth = ./bluetooth.nix;
  containers = ./containers.nix;
  doas = ./doas.nix;
  docker = ./docker.nix;
  fail2ban = ./fail2ban.nix;
  fwupd = ./fwupd.nix;
  gaming = ./gaming.nix;
  git = ./git.nix;
  gnome = ./gnome;
  i18n = ./i18n.nix;
  java = ./java.nix;
  javascript = ./javascript.nix;
  keyboard = ./keyboard.nix;
  kotlin = ./kotlin.nix;
  laptop-power-management = ./laptop-power-management.nix;
  nano = ./nano.nix;
  nautilus = ./nautilus.nix;
  nftables = ./nftables.nix;
  nginx = ./nginx.nix;
  nix = ./nix.nix;
  nix-garbage-collection = ./nix-garbage-collection.nix;
  nvd = ./nvd.nix;
  peripherals = ./peripherals.nix;
  podman = ./podman.nix;
  printing = ./printing.nix;
  python = ./python.nix;
  shell = ./shell.nix;
  ssh = ./ssh.nix;
  sudo-rs = ./sudo-rs.nix;
  tmp-management = ./tmp-management.nix;
  trash-management = ./trash-management.nix;
  util = ./util.nix;
  virtualbox = ./virtualbox.nix;
  zfs = ./zfs.nix;
}
