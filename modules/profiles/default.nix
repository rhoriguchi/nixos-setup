{
  headless = import ./headless.nix;
  headful = import ./headful.nix;

  displaylink = import ./displaylink.nix;
  doas = import ./doas.nix;
  docker = import ./docker.nix;
  fancy-motd = import ./fancy-motd.nix;
  git = import ./git.nix;
  gnome = import ./gnome.nix;
  hidpi = import ./hidpi.nix;
  i18n = import ./i18n.nix;
  java = import ./java.nix;
  javascript = import ./javascript.nix;
  k8s = import ./k8s.nix;
  keyboard = import ./keyboard.nix;
  kotlin = import ./kotlin.nix;
  laptop-power-management = import ./laptop-power-management.nix;
  nginx = import ./nginx.nix;
  nix = import ./nix.nix;
  nvd = import ./nvd.nix;
  podman = import ./podman.nix;
  printing = import ./printing.nix;
  python = import ./python.nix;
  util = import ./util.nix;
  zfs = import ./zfs.nix;
  zsh = import ./zsh.nix;
}
